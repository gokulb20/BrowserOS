type Scope = {
  setTag: (_key: string, _value: unknown) => Scope
  setContext: (_name: string, _context: Record<string, unknown> | null) => Scope
  setExtra: (_key: string, _value: unknown) => Scope
  setUser: (_user: Record<string, unknown> | null) => Scope
  setLevel: (_level: string) => Scope
}

const noopScope: Scope = {
  setTag: () => noopScope,
  setContext: () => noopScope,
  setExtra: () => noopScope,
  setUser: () => noopScope,
  setLevel: () => noopScope,
}

export const Sentry = {
  captureException(_err: unknown): void {},
  captureMessage(_msg: string): void {},
  setUser(_user: Record<string, unknown> | null): void {},
  setContext(_name: string, _context: Record<string, unknown> | null): void {},
  setTag(_key: string, _value: unknown): void {},
  getCurrentScope(): Scope {
    return noopScope
  },
  withScope(cb: (scope: Scope) => void): void {
    cb(noopScope)
  },
}
