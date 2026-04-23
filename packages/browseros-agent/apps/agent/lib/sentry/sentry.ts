type ExceptionOptions = {
  extra?: Record<string, unknown>
  tags?: Record<string, string | number | boolean>
}

type ReactErrorInfo = { componentStack?: string | null }
type ReactErrorHandler = (error: unknown, info: ReactErrorInfo) => void

/** @public */
export const sentry = {
  captureException(_err: unknown, _options?: ExceptionOptions): void {},
  setUser(_user: { id?: string; email?: string } | null): void {},
  reactErrorHandler(cb?: ReactErrorHandler): ReactErrorHandler {
    return (error, info) => {
      cb?.(error, info)
    }
  },
}
