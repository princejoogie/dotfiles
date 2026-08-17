// Generate images with xAI Grok Imagine from a normal chat session.
// Imagine models are image APIs, not chat models — selecting them as the
// session model is what produced the HTTP 400.

const DEFAULT_MODEL = "grok-imagine-image-2.0"
const DEFAULT_VIDEO_MODEL = "grok-imagine-video-1.5"
const IMAGE_URL = "https://api.x.ai/v1/images/generations"
const IMAGE_EDIT_URL = "https://api.x.ai/v1/images/edits"
const VIDEO_URL = "https://api.x.ai/v1/videos/generations"
const VIDEO_EDIT_URL = "https://api.x.ai/v1/videos/edits"
const TOKEN_URL = "https://auth.x.ai/oauth2/token"
const XAI_CLIENT_ID = "b1a00492-073a-47ea-816f-4c329264a828"
const AUTH_PATH = `${process.env.HOME}/.local/share/opencode/auth.json`
const MODELS = [
  "grok-imagine-image-2.0",
  "grok-imagine-image",
  "grok-imagine-image-quality",
]
const VIDEO_MODELS = ["grok-imagine-video-1.5", "grok-imagine-video"]

function extensionFor(mime) {
  if (mime === "image/png") return "png"
  if (mime === "image/webp") return "webp"
  return "jpg"
}

function slug(text) {
  const value = String(text)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 48)
  return value || "imagine"
}

function decodeJwtExp(token) {
  try {
    const payload = JSON.parse(Buffer.from(token.split(".")[1], "base64url").toString())
    return typeof payload.exp === "number" ? payload.exp * 1000 : undefined
  } catch {
    return undefined
  }
}

function credentialToken(cred) {
  if (!cred || typeof cred !== "object") return
  if (typeof cred.access === "string" && cred.access) return cred.access
  if (typeof cred.key === "string" && cred.key) return cred.key
  if (typeof cred.value === "string" && cred.value) return cred.value
  if (cred.value && typeof cred.value === "object") return credentialToken(cred.value)
}

async function refreshAccessToken(refresh) {
  const response = await fetch(TOKEN_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      Accept: "application/json",
    },
    body: new URLSearchParams({
      grant_type: "refresh_token",
      refresh_token: refresh,
      client_id: XAI_CLIENT_ID,
    }),
  })
  const body = await response.text()
  if (!response.ok) {
    throw new Error(`xAI token refresh failed (${response.status}): ${body.slice(0, 240)}`)
  }
  const tokens = JSON.parse(body)
  if (!tokens.access_token) throw new Error("xAI token refresh returned no access_token")
  return tokens.access_token
}

async function tokenFromAuthFile() {
  const { readFile } = await import("node:fs/promises")
  const raw = JSON.parse(await readFile(AUTH_PATH, "utf8"))
  const xai = raw.xai
  if (!xai) return
  if (xai.type === "api" && xai.key) return xai.key
  if (xai.access) {
    const exp = xai.expires ?? decodeJwtExp(xai.access)
    if (!exp || exp - 60_000 > Date.now()) return xai.access
  }
  if (xai.refresh) return refreshAccessToken(xai.refresh)
}

async function resolveToken(ctx) {
  if (process.env.XAI_API_KEY) return process.env.XAI_API_KEY

  try {
    const connection = await ctx.integration.connection.active("xai")
    if (connection) {
      const cred = await ctx.integration.connection.resolve(connection)
      const token = credentialToken(cred)
      if (token) {
        const exp = cred?.expires ?? decodeJwtExp(token)
        if (!exp || exp - 60_000 > Date.now()) return token
      }
      if (cred?.refresh) return refreshAccessToken(cred.refresh)
      if (token) return token
    }
  } catch {
    // Fall back to the stored xAI login for this machine.
  }

  const fallback = await tokenFromAuthFile()
  if (fallback) return fallback
  throw new Error("xAI is not connected. Run `opencode2 auth` and connect xAI, or set XAI_API_KEY.")
}

function mimeFromPath(filePath) {
  const lower = String(filePath).toLowerCase()
  if (lower.endsWith(".png")) return "image/png"
  if (lower.endsWith(".webp")) return "image/webp"
  if (lower.endsWith(".gif")) return "image/gif"
  if (lower.endsWith(".mp4")) return "video/mp4"
  if (lower.endsWith(".webm")) return "video/webm"
  if (lower.endsWith(".mov")) return "video/quicktime"
  return "image/jpeg"
}

function normalizeMediaInput(value) {
  if (!value) return
  return String(value).replace(/^file:\/\//, "")
}

async function mediaUrlFromInput(value) {
  const input = normalizeMediaInput(value)
  if (!input) return
  if (input.startsWith("data:") || input.startsWith("http://") || input.startsWith("https://")) return input
  const { readFile } = await import("node:fs/promises")
  const { resolve } = await import("node:path")
  const abs = resolve(input)
  const bytes = await readFile(abs)
  return `data:${mimeFromPath(abs)};base64,${bytes.toString("base64")}`
}

async function mediaRefs(values) {
  const items = (Array.isArray(values) ? values : [values]).map(normalizeMediaInput).filter(Boolean)
  return Promise.all(items.map(async (value) => ({ url: await mediaUrlFromInput(value) })))
}

async function xaiFetch(token, url, init = {}) {
  const response = await fetch(url, {
    ...init,
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: "application/json",
      ...(init.headers || {}),
    },
  })
  const raw = await response.text()
  let payload
  try {
    payload = raw ? JSON.parse(raw) : {}
  } catch {
    payload = { raw }
  }
  if (!response.ok) {
    throw new Error(`Grok Imagine failed (${response.status}): ${raw.slice(0, 400)}`)
  }
  return payload
}

async function pollVideo(token, requestId, progress) {
  const started = Date.now()
  const timeoutMs = 8 * 60 * 1000
  while (Date.now() - started < timeoutMs) {
    const status = await xaiFetch(token, `https://api.x.ai/v1/videos/${requestId}`)
    const state = status.status || status.state
    if (progress) await progress({ phase: `video ${state || "processing"}` })
    if (state === "done" || status.video?.url) return status
    if (state === "failed" || state === "expired") {
      throw new Error(`Grok Imagine video ${state}: ${JSON.stringify(status).slice(0, 400)}`)
    }
    await new Promise((resolve) => setTimeout(resolve, 5000))
  }
  throw new Error(`Grok Imagine video timed out waiting for ${requestId}`)
}

export default {
  id: "local.grok-imagine",
  setup: async (ctx) => {
    await ctx.tool.transform((tools) => {
      tools.add({
        name: "generate_image",
        description:
          "Generate or reimagine an image with xAI Grok Imagine and save it to disk. Pass image/images to edit attached stills. Do not select grok-imagine-* as the session/chat model.",
        options: { codemode: true },
        input: {
          type: "object",
          additionalProperties: false,
          required: ["prompt"],
          properties: {
            prompt: {
              type: "string",
              description: "Image prompt",
            },
            model: {
              type: "string",
              description: `Imagine model. Default: ${DEFAULT_MODEL}`,
              enum: MODELS,
            },
            aspect_ratio: {
              type: "string",
              description: "Output aspect ratio",
              enum: ["1:1", "16:9", "9:16", "4:3", "3:4", "3:2", "2:3", "2:1", "1:2", "19.5:9", "9:19.5", "20:9", "9:20", "auto"],
            },
            resolution: {
              type: "string",
              description: "Output resolution",
              enum: ["1k", "2k"],
            },
            image: {
              type: "string",
              description: "Local path, file://, data URL, or https URL of a still to reimagine.",
            },
            images: {
              type: "array",
              description: "Multiple stills to reimagine. Refer to them as <IMAGE_0>, <IMAGE_1>, ... in the prompt.",
              items: { type: "string" },
            },
            path: {
              type: "string",
              description: "Optional destination file path. Defaults to a timestamped file in the current directory.",
            },
          },
        },
        output: {
          type: "object",
          additionalProperties: false,
          required: ["path", "model", "prompt"],
          properties: {
            path: { type: "string" },
            model: { type: "string" },
            prompt: { type: "string" },
            mime: { type: "string" },
          },
        },
        execute: async (input) => {
          const { writeFile, mkdir } = await import("node:fs/promises")
          const { dirname, resolve } = await import("node:path")

          const model = MODELS.includes(input.model) ? input.model : DEFAULT_MODEL
          const token = await resolveToken(ctx)
          const refs = await mediaRefs([input.image, ...(input.images || [])])
          const body = {
            model,
            prompt: input.prompt,
            n: 1,
            response_format: "b64_json",
          }
          if (input.aspect_ratio) body.aspect_ratio = input.aspect_ratio
          if (input.resolution) body.resolution = input.resolution
          if (refs.length === 1) body.image = refs[0]
          if (refs.length > 1) body.images = refs

          const payload = await xaiFetch(token, refs.length ? IMAGE_EDIT_URL : IMAGE_URL, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body),
          })
          const item = payload?.data?.[0]
          if (!item?.b64_json && !item?.url) {
            throw new Error("Grok Imagine returned no image data")
          }

          const mime = item.mime_type || "image/jpeg"
          const dest = resolve(
            input.path || `${slug(input.prompt)}-${Date.now()}.${extensionFor(mime)}`,
          )
          await mkdir(dirname(dest), { recursive: true })

          if (item.b64_json) {
            await writeFile(dest, Buffer.from(item.b64_json, "base64"))
          } else {
            const image = await fetch(item.url)
            if (!image.ok) throw new Error(`Failed to download generated image (${image.status})`)
            await writeFile(dest, Buffer.from(await image.arrayBuffer()))
          }

          const text = `Saved Grok Imagine image to ${dest}`
          return {
            output: { path: dest, model, prompt: input.prompt, mime },
            content: [
              { type: "text", text },
              {
                type: "file",
                uri: item.b64_json ? `data:${mime};base64,${item.b64_json}` : `file://${dest}`,
                mime,
                name: dest,
              },
            ],
          }
        },
      })

      tools.add({
        name: "generate_video",
        description:
          "Generate, animate, or reimagine a video with xAI Grok Imagine Video and save it as an mp4. Pass image/images to animate stills, or video to edit an attached clip. Do not select grok-imagine-video* as the session/chat model.",
        options: { codemode: true },
        input: {
          type: "object",
          additionalProperties: false,
          required: ["prompt"],
          properties: {
            prompt: {
              type: "string",
              description: "Motion / video prompt",
            },
            image: {
              type: "string",
              description: "Local still to animate. Image-to-video start frame.",
            },
            images: {
              type: "array",
              description: "Reference stills. Do not combine with image.",
              items: { type: "string" },
            },
            video: {
              type: "string",
              description: "Local path, file://, data URL, or https URL of a clip to reimagine/edit.",
            },
            model: {
              type: "string",
              description: `Video model. Default: ${DEFAULT_VIDEO_MODEL}`,
              enum: VIDEO_MODELS,
            },
            duration: {
              type: "integer",
              description: "Clip length in seconds. Default: 6",
            },
            aspect_ratio: {
              type: "string",
              description: "Output aspect ratio",
              enum: ["1:1", "16:9", "9:16", "4:3", "3:4"],
            },
            resolution: {
              type: "string",
              description: "Output resolution. 1080p is image-to-video on grok-imagine-video-1.5 only.",
              enum: ["480p", "720p", "1080p"],
            },
            path: {
              type: "string",
              description: "Optional destination .mp4 path",
            },
          },
        },
        output: {
          type: "object",
          additionalProperties: false,
          required: ["path", "model", "prompt"],
          properties: {
            path: { type: "string" },
            model: { type: "string" },
            prompt: { type: "string" },
            request_id: { type: "string" },
            url: { type: "string" },
          },
        },
        execute: async (input, context) => {
          const { writeFile, mkdir } = await import("node:fs/promises")
          const { dirname, resolve } = await import("node:path")

          const model = VIDEO_MODELS.includes(input.model) ? input.model : DEFAULT_VIDEO_MODEL
          const token = await resolveToken(ctx)
          const duration = Number(input.duration)
          const body = {
            model,
            prompt: input.prompt,
            duration: Number.isFinite(duration) && duration > 0 ? duration : 6,
          }
          if (input.aspect_ratio) body.aspect_ratio = input.aspect_ratio
          if (input.resolution) body.resolution = input.resolution
          if (input.video) body.video = { url: await mediaUrlFromInput(input.video) }
          else if (input.image) body.image = { url: await mediaUrlFromInput(input.image) }
          else if (input.images?.length) body.reference_images = await mediaRefs(input.images)

          if (context?.progress) await context.progress({ phase: input.video ? "editing video" : "starting video" })
          const started = await xaiFetch(token, input.video ? VIDEO_EDIT_URL : VIDEO_URL, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body),
          })
          const requestId = started.request_id || started.id
          if (!requestId) throw new Error(`Grok Imagine video returned no request_id: ${JSON.stringify(started).slice(0, 300)}`)

          const finished = await pollVideo(token, requestId, context?.progress)
          const url = finished.video?.url || finished.url
          if (!url) throw new Error("Grok Imagine video finished without a URL")

          const dest = resolve(input.path || `${slug(input.prompt)}-${Date.now()}.mp4`)
          await mkdir(dirname(dest), { recursive: true })
          const video = await fetch(url)
          if (!video.ok) throw new Error(`Failed to download generated video (${video.status})`)
          await writeFile(dest, Buffer.from(await video.arrayBuffer()))

          const text = `Saved Grok Imagine video to ${dest}`
          return {
            output: { path: dest, model, prompt: input.prompt, request_id: requestId, url },
            content: [
              { type: "text", text },
              { type: "file", uri: `file://${dest}`, mime: "video/mp4", name: dest },
            ],
          }
        },
      })
    })

    // Slash commands live in ~/.config/opencode/command/{imagine,imagine-video}.md
  },
}
