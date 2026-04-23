import { useEffect, useState } from 'react'
import { NEWTAB_OPENED_EVENT } from '@/lib/constants/analyticsEvents'
import { track } from '@/lib/metrics/track'
import { NewTabBranding } from './NewTabBranding'
import { NewTabTip } from './NewTabTip'
import { TopSites } from './TopSites'

export const NewTab = () => {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
    track(NEWTAB_OPENED_EVENT)
  }, [])

  return (
    <div className="pt-[max(20vh,16px)]">
      <div className="relative w-full space-y-10 md:w-3xl">
        <NewTabBranding />
        {mounted && <TopSites />}
        {mounted && <NewTabTip />}
      </div>
    </div>
  )
}
