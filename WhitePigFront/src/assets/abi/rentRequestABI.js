export const rentRequestABI = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_pm",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_uInfo",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [],
    "name": "conRequestCount",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_conRequestId",
        "type": "uint256"
      }
    ],
    "name": "getConRequestById",
    "outputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "conRequestId",
            "type": "uint256"
          },
          {
            "internalType": "address",
            "name": "sender",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "lord",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "propertyId",
            "type": "uint256"
          },
          {
            "internalType": "string",
            "name": "content",
            "type": "string"
          },
          {
            "internalType": "bool",
            "name": "approved",
            "type": "bool"
          }
        ],
        "internalType": "struct IrentRequest.ConRequest",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bool",
        "name": "_isRoomer",
        "type": "bool"
      }
    ],
    "name": "getConRequests",
    "outputs": [
      {
        "internalType": "uint256[]",
        "name": "",
        "type": "uint256[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_rentRequestId",
        "type": "uint256"
      }
    ],
    "name": "getRentRequestById",
    "outputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "rentRequestId",
            "type": "uint256"
          },
          {
            "internalType": "address",
            "name": "sender",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "lord",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "propertyId",
            "type": "uint256"
          },
          {
            "internalType": "string",
            "name": "content",
            "type": "string"
          },
          {
            "internalType": "bool",
            "name": "approved",
            "type": "bool"
          }
        ],
        "internalType": "struct IrentRequest.RentRequest",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bool",
        "name": "_isRoomer",
        "type": "bool"
      }
    ],
    "name": "getRentRequests",
    "outputs": [
      {
        "internalType": "uint256[]",
        "name": "",
        "type": "uint256[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_conRequestId",
        "type": "uint256"
      },
      {
        "internalType": "bool",
        "name": "_isApproved",
        "type": "bool"
      }
    ],
    "name": "handleConRequest",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_rentRequestId",
        "type": "uint256"
      },
      {
        "internalType": "bool",
        "name": "_isApproved",
        "type": "bool"
      }
    ],
    "name": "handleRentRequest",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "rentRequestCount",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_propertyId",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "_content",
        "type": "string"
      }
    ],
    "name": "sendConRequest",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_propertyId",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "_content",
        "type": "string"
      }
    ],
    "name": "sendRentRequest",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]