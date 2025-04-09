export const propertyMarketABI = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_pm",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_usdt",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_user",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_dao",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_monthlyRent",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "_propertyType",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "_description",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "_photos",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "_location",
        "type": "string"
      }
    ],
    "name": "addPropertyMarket",
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
      }
    ],
    "name": "chargeback",
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
      }
    ],
    "name": "checkIsCompleted",
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
        "name": "_description",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "_proof",
        "type": "string"
      }
    ],
    "name": "complain",
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
    "name": "getAllProperty",
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
        "name": "_dealId",
        "type": "uint256"
      }
    ],
    "name": "getDisputeResult",
    "outputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "disputeId",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "dealId",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "deadline",
            "type": "uint256"
          },
          {
            "internalType": "string",
            "name": "disputeDescription",
            "type": "string"
          },
          {
            "internalType": "string",
            "name": "proof",
            "type": "string"
          },
          {
            "internalType": "uint256",
            "name": "votesFor",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "votesAgainst",
            "type": "uint256"
          },
          {
            "internalType": "bool",
            "name": "executed",
            "type": "bool"
          },
          {
            "internalType": "address",
            "name": "roe",
            "type": "address"
          }
        ],
        "internalType": "struct IRentDeal.Dispute",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getMyProperty",
    "outputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "propertyId",
            "type": "uint256"
          },
          {
            "internalType": "bool",
            "name": "isAvailable",
            "type": "bool"
          },
          {
            "internalType": "bool",
            "name": "isWithdraw",
            "type": "bool"
          },
          {
            "internalType": "uint256",
            "name": "monthlyRent",
            "type": "uint256"
          },
          {
            "internalType": "string",
            "name": "propertyType",
            "type": "string"
          },
          {
            "internalType": "string",
            "name": "description",
            "type": "string"
          },
          {
            "internalType": "string",
            "name": "photos",
            "type": "string"
          },
          {
            "internalType": "string",
            "name": "location",
            "type": "string"
          },
          {
            "internalType": "address",
            "name": "owner",
            "type": "address"
          }
        ],
        "internalType": "struct propertyMarket.Property[]",
        "name": "",
        "type": "tuple[]"
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
        "internalType": "address",
        "name": "_owner",
        "type": "address"
      }
    ],
    "name": "getRemark",
    "outputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "grade",
            "type": "uint256"
          },
          {
            "internalType": "string",
            "name": "wards",
            "type": "string"
          },
          {
            "internalType": "bool",
            "name": "isRemark",
            "type": "bool"
          }
        ],
        "internalType": "struct IRentDeal.Remark",
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
        "internalType": "uint256",
        "name": "_propertyId",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_grade",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "_wards",
        "type": "string"
      }
    ],
    "name": "remark",
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
        "internalType": "uint256",
        "name": "_monthCount",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "_rentContract",
        "type": "string"
      }
    ],
    "name": "rent",
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