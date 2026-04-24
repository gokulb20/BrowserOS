import { StepOne } from './StepOne'
import { StepTwo } from './StepTwo'

// Crewm8: reduced from 4 steps to 2. Dropped the agent-specific push
// (Personality / Connect Apps) since Crewm8 leads with a regular browser
// experience — agent setup is discoverable from Settings, not front-loaded
// in onboarding. StepSoul.tsx and StepConnectApps.tsx remain on disk so
// upstream BrowserOS merges don't churn; they're just unlinked.
export const steps = [
  {
    id: 1,
    name: 'About You',
    component: StepOne,
  },
  {
    id: 2,
    name: 'Sign In',
    component: StepTwo,
  },
]
