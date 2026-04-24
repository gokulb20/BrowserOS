import type { FC } from 'react'
import { Outlet } from 'react-router'
import { BrowserOSIcon } from '@/lib/llm-providers/providerIcons'

export const AuthLayout: FC = () => {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-background p-4">
      <div className="mb-8 flex flex-col items-center">
        <BrowserOSIcon size={64} />
      </div>
      <Outlet />
    </div>
  )
}
