import { motion } from 'motion/react'
import type { FC } from 'react'
import WordmarkSvg from '@/assets/crewm8-wordmark.svg'

export const NewTabBranding: FC = () => {
  return (
    <div className="text-center">
      <motion.div
        layoutId="new-tab-branding"
        transition={{ type: 'keyframes', damping: 20, stiffness: 300 }}
        className="flex items-center justify-center"
      >
        <div
          className="h-16 w-64 bg-foreground"
          style={{
            WebkitMaskImage: `url(${WordmarkSvg})`,
            WebkitMaskRepeat: 'no-repeat',
            WebkitMaskPosition: 'center',
            WebkitMaskSize: 'contain',
            maskImage: `url(${WordmarkSvg})`,
            maskRepeat: 'no-repeat',
            maskPosition: 'center',
            maskSize: 'contain',
          }}
          role="img"
          aria-label="Crewm8"
        />
      </motion.div>
    </div>
  )
}
