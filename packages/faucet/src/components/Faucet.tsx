import * as React from 'react'

import { useContractWrite, usePrepareContractWrite, useWaitForTransaction } from 'wagmi'

export function Faucet() {
  const {
    config, error: prepareError,
    isError: isPrepareError,
  } = usePrepareContractWrite({
    address: '0xB11b1E354752b35faF001940e3e03aE381b99adD',
    abi: [{
      name: 'requestTokens',
      type: 'function',
      stateMutability: 'nonpayable',
      inputs: [],
      outputs: [],
    }],
    functionName: 'requestTokens',
    value: BigInt(0),
  })

  const {
    data,
    error,
    isError,
    write,
  } = useContractWrite(config)


  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  })

  console.log({ write, isLoading })

  return (
    <div>
      <button disabled={!write || isLoading} onClick={() => write && write()}>
        {isLoading ? 'Dispensing tokens' : 'Request tokens'}
      </button>
      {isSuccess && (
        <div>Tokens dispensed successfully!</div>
      )}
      {(isPrepareError || isError) && (
        <div>Error: {(prepareError || error)?.message}</div>
      )}
    </div>
  )
}
