# Cryptoreal RWA: Tokenización de Activos Reales

Prototipo educativo de un token ERC-20 para representar activos reales (por ejemplo, inmuebles) con control de acceso KYC y pausa de emergencia on-chain.

> **Estado:** prototipo sin auditar. No usar en producción ni con fondos reales.

## Características

- Token ERC-20 (`CRRWA`) con suministro máximo de 10.000.000 tokens.
- Lista blanca KYC: solo direcciones aprobadas pueden enviar o recibir tokens.
- Tokenización de activos con identificador único (`bytes32`) para evitar duplicados.
- Pausa de emergencia (`pause` / `unpause`).
- Propiedad en dos pasos (`Ownable2Step`) para evitar perder el control por error.
- Custom errors para menor consumo de gas.

## Stack

- Solidity `^0.8.20`
- OpenZeppelin Contracts v5
- Remix IDE (desarrollo y pruebas manuales)

## Despliegue local en Remix

1. Abre [remix.ethereum.org](https://remix.ethereum.org) y pega `CryptorealRWA_V2.sol`.
2. Compila con la versión `0.8.20`.
3. En *Deploy & Run Transactions*, elige el entorno **Remix VM** y el contrato `CryptorealRWA_V2`.
4. Introduce `initialSupply` (por ejemplo `1000000`) y pulsa **Deploy**.
5. Verifica con `balanceOf(<tu_direccion>)`. Debe devolver `1000000000000000000000000`.

> Remix VM es una blockchain simulada en el navegador. Las direcciones y hashes que genera desaparecen al recargar la página.

## Uso

### Aprobar KYC (obligatorio antes de recibir tokens)

```
approveKYC(0xDireccionDelInversor)
```

### Tokenizar un activo

```
tokenizeAsset(
  investor: 0xDireccionDelInversor,
  amount: 100,
  assetId: 0x636173612d303031000000000000000000000000000000000000000000000000
)
```

- `amount` se expresa en tokens enteros (el contrato multiplica por 10^18).
- `assetId` de ejemplo: el texto `casa-001` codificado en `bytes32`. En un entorno real se recomienda usar `keccak256("casa-001")`.
- Si el `assetId` ya fue tokenizado, la transacción revierte con `AssetAlreadyTokenized`.

### Transferir tokens

```
transfer(
  to: 0xDireccionDelReceptor,
  value: 100000000000000000000   // 100 tokens
)
```

Si el emisor o el receptor no tienen KYC, la transacción revierte con `NotKYC(address)`.

## Funciones de administración (solo owner)

| Función | Descripción |
|---|---|
| `approveKYC(address)` | Aprueba una dirección |
| `revokeKYC(address)` | Revoca la aprobación |
| `tokenizeAsset(address, uint256, bytes32)` | Emite tokens por un activo |
| `pause()` / `unpause()` | Detiene o reanuda todas las transferencias |
| `transferOwnership(address)` / `acceptOwnership()` | Cambio de owner en dos pasos |

> **Importante:** al revocar el KYC de una cuenta, sus tokens quedan congelados, porque ya no puede enviarlos. El contrato no incluye `forceTransfer` ni `burn`.

## Diseño de seguridad

La validación de KYC y pausa se centraliza en el hook `_update` de OpenZeppelin v5, de modo que cubre transferencias, mint y burn sin depender de sobrescribir `transfer` y `transferFrom`.

| Aspecto | V1 | V2 |
|---|---|---|
| Validación | Override de `transfer` / `transferFrom` | Hook `_update` |
| KYC | Solo receptor, sin revocación | Emisor y receptor, con `revokeKYC` |
| Errores | `require` con strings | Custom errors |
| `assetId` | `string` | `bytes32` |
| Propiedad | `Ownable` | `Ownable2Step` |
| Cap en constructor | Comparación con unidades distintas | Comparación con valor escalado |

## Limitaciones conocidas

- El owner es una sola cuenta con poder total (KYC, mint, pausa). Para producción se recomienda un multisig o roles con `AccessControl`.
- No hay tests automatizados todavía.
- No ha sido auditado.
- No existe mecanismo para recuperar tokens de cuentas con KYC revocado ni para des-tokenizar un activo.
- El cumplimiento regulatorio real requiere un proceso legal y de KYC off-chain que este contrato no cubre.

## Troubleshooting

**Error `bad address checksum` en Remix:** pega la dirección completamente en minúsculas.

## Roadmap

- [ ] Tests con Foundry o Hardhat (cap, pausa, KYC, tokenización duplicada)
- [ ] Despliegue en Sepolia y verificación en Etherscan
- [ ] Función de recuperación / burn controlado
- [ ] Roles con `AccessControl`

## Licencia

MIT
