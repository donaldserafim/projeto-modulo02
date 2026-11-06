# Evidências da entrega

Ainda não há execução remota comprovada. Arquivos de resultado não serão inventados: SBOM, CVEs, digests publicados, assinaturas, verificações e print serão produzidos pelo GitHub Actions.

O **Summary** organiza os controles, o comparativo antes/depois, vulnerabilidades e verificações Cosign, também após falhas, se o runner continuar disponível e a etapa conseguir executar. O link de download aparece após o upload bem-sucedido.

Após uma execução bem-sucedida de **Supply chain**, baixar pelo Summary o artifact `supply-chain-<run_id>-<tentativa>` na página da execução e preservar seus arquivos em uma subpasta identificada pelo ID. O pacote inclui os testes e scans repetidos no próprio workflow de publicação.

Antes de incluir os arquivos na entrega, o usuário deve confirmar o resultado remoto `success`, revisar os arquivos baixados e registrar no README da subpasta a URL da execução e o `analyzed_commit` de `manifest.json`. O usuário cuida do versionamento; a versão que incorpora as evidências deve ser distinguida da versão analisada. Preservar os originais e não alterar os JSONs para ajustar resultados.

A imagem-base é histórica e intencionalmente vulnerável. O achado concreto só será conhecido após o scan. `trivy-before.png` é uma captura de navegador do relatório real produzido no runner, com a ficha do achado e a tabela. Não é uma captura da interface do GitHub.

## Conferência dos entregáveis

| Requisito | Arquivos a preservar do artifact Supply chain |
|---|---|
| Política testada | `opa-tests.txt`, `opa-coverage.json`, `policy-before.json` e `policy-after.json` |
| SBOM gerado | `sbom-before.cdx.json`, `sbom-after.cdx.json` e `sbom-published.cdx.json` |
| Vulnerabilidade real e print | `trivy-before.json`, `trivy-before.txt`, `selected-finding.json`, `vulnerability.md` e `trivy-before.png` |
| Assinatura e verificação | `signed-image.txt`, `cosign-sign.txt`, `cosign-verify.json`, `cosign-sbom.json` e `trusted-identity.txt` |
| Rejeição da variante | `tampered-image.txt`, `cosign-tampered.stderr`, `cosign-tampered.exit-code` e `tampered-assertion.txt` |
| Comandos shell capturados | `command-logs/*.log`; registros nativos das Actions `uses:` ficam na execução |
| Rastreabilidade | `manifest.json`, `tool-versions.txt`, locks e `base-image.txt` |

As assinaturas e atestações são publicadas no registry; os artifacts preservam os relatórios da operação e da verificação, não um pacote de verificação offline. Manter as imagens e seus dados de assinatura disponíveis para a avaliação.

O manifesto contém os checksums dos arquivos coletados e o estado naquele momento. O resultado posterior do upload deve ser conferido no Summary. Dados de uma execução interrompida podem estar incompletos; não usá-los como comprovação de aprovação.
