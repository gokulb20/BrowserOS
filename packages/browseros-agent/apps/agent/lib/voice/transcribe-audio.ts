// Crewm8: voice transcription is disabled by default.
// Upstream BrowserOS points this at its own llm.browseros.com gateway;
// Crewm8 users wanting voice input must configure their own Whisper-
// compatible endpoint (to be added as a settings pref). Until then,
// calling transcribeAudio throws a clear error instead of silently
// phoning home to browseros.com.
const GATEWAY_URL = ''

interface TranscribeResponse {
  text: string
}

export async function transcribeAudio(audioBlob: Blob): Promise<string> {
  if (!GATEWAY_URL) {
    throw new Error(
      'Voice transcription is not configured. Set a transcription endpoint in Settings to enable voice input.',
    )
  }

  const formData = new FormData()
  formData.append('file', audioBlob, 'recording.webm')
  formData.append('response_format', 'json')

  const response = await fetch(`${GATEWAY_URL}/api/transcribe`, {
    method: 'POST',
    body: formData,
    signal: AbortSignal.timeout(30_000),
  })

  if (!response.ok) {
    const errorBody: { error?: string } = await response
      .json()
      .catch(() => ({ error: 'Transcription failed' }))
    throw new Error(
      errorBody.error || `Transcription failed: ${response.status}`,
    )
  }

  const result: TranscribeResponse = await response.json()
  return result.text || ''
}
