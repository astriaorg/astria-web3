import { useAccount } from 'wagmi'

import { Account } from './components/Account'
import { Connect } from './components/Connect'
import { Faucet } from './components/Faucet'
import { NetworkSwitcher } from './components/NetworkSwitcher'

export function App() {
  const { isConnected } = useAccount()

  return (
    <>
      <h1>Astria Faucet</h1>

      <Connect/>

      {isConnected && (
        <>
          <Account/>
          <hr/>
          <NetworkSwitcher/>
          <hr/>
          <Faucet/>
        </>
      )}
    </>
  )
}
