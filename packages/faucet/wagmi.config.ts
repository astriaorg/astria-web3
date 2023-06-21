import { defineConfig } from '@wagmi/cli'
import { foundry, react } from '@wagmi/cli/plugins'
import { astria } from './src/chains'

export default defineConfig({
  out: 'src/generated.ts',
  plugins: [
    foundry({
      // path to foundry project
      project: './contracts',
      deployments: {
        Faucet: {
          [astria.id]: '0xB11b1E354752b35faF001940e3e03aE381b99adD',
        },
      },
    }),
    react(),
  ],
})
