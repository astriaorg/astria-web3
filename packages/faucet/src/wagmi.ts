import { configureChains, createConfig } from 'wagmi'
import { InjectedConnector } from 'wagmi/connectors/injected'
import { MetaMaskConnector } from 'wagmi/connectors/metaMask'

import { jsonRpcProvider } from 'wagmi/providers/jsonRpc'

import { astria } from './chains'


const { chains, publicClient, webSocketPublicClient } = configureChains(
  [astria],
  [
    jsonRpcProvider({
      rpc: () => ({
        http: `http://executor.astria.localdev.me`,
      }),
    }),
  ],
)

export const config = createConfig({
  autoConnect: true,
  connectors: [
    new MetaMaskConnector({ chains }),
    new InjectedConnector({
      chains,
      options: {
        name: 'Injected',
        shimDisconnect: true,
      },
    }),
  ],
  publicClient,
  webSocketPublicClient,
})
