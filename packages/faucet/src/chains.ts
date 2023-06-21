import { Chain } from 'wagmi'

export const astria = {
  id: 912_559,
  name: 'Astria',
  network: 'astria',
  nativeCurrency: {
    decimals: 18,
    name: 'Astria',
    symbol: 'RIA',
  },
  rpcUrls: {
    public: { http: ['http://executor.astria.localdev.me'] },
    default: { http: ['http://executor.astria.localdev.me'] },
  },
} as const satisfies Chain
