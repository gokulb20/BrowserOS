export interface MetricsConfig {
  client_id?: string
  install_id?: string
  browseros_version?: string
  chromium_version?: string
  server_version?: string
  [key: string]: string | undefined
}

class MetricsService {
  private config: MetricsConfig | null = null

  initialize(config: MetricsConfig): void {
    this.config = { ...this.config, ...config }
  }

  isEnabled(): boolean {
    return false
  }

  getClientId(): string | null {
    return this.config?.client_id ?? null
  }

  log(_eventName: string, _properties: Record<string, unknown> = {}): void {}

  async shutdown(): Promise<void> {}
}

export const metrics = new MetricsService()
