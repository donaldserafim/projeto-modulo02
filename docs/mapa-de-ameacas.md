# Mapa de ameaças

Os controles abaixo estão preparados nos arquivos do projeto; seus resultados dependem da execução no Actions. Revisão de alterações e proteção do repositório são administradas pelo usuário.

| Fase / entrada do atacante | Efeito possível | Controle demonstrado | Evidência produzida no Actions |
|---|---|---|---|
| Source: alteração do Dockerfile para root | Mais privilégios disponíveis caso a aplicação seja explorada | Regra Rego sobre `Config.User` da imagem construída e asserção do UID em execução | `opa-tests.txt`, `image-*.json`, `policy-*.json`, `run-*.txt` |
| Dependências: pacote vulnerável na base | Exploração de vulnerabilidade conhecida | Base identificada por digest, inventário Syft e análise Trivy | `base-image.txt`, `sbom-*.cdx.json`, `trivy-*.json`, `selected-finding.json` |
| Build: alteração do workflow ou da ferramenta | Produção e possível assinatura de código comprometido | Actions por SHA, ferramentas por versão e permissões mínimas; revisão e checks obrigatórios dependem da configuração do usuário | Commit, workflow versionado, `tools.lock.json` e `manifest.json` |
| Distribuição: troca da imagem legítima por variante modificada | Consumidor recebe conteúdo diferente | Cosign keyless por digest, issuer e identidade exata do workflow; verificação no workflow de demonstração | `signed-image.txt`, `tampered-image.txt`, `cosign-verify.json`, `cosign-tampered.stderr` e código de retorno |

A simulação de ataque adiciona somente um arquivo marcador à imagem, publica outro digest e não o assina. Quando aprovado, o teste comprova rejeição dessa substituição sem assinatura confiável; não executa malware. O controle de usuário reduz privilégios; Syft e Trivy fornecem inventário e detecção, sem corrigir automaticamente os pacotes.

**Conexão com SolarWinds:** a CISA descreve a inclusão de código malicioso no ciclo de produção e sua distribuição com certificado legítimo. Isso mostra o limite da assinatura: ela não identifica sozinha um build comprometido. A demonstração cobre a substituição posterior sem assinatura; proteger source e builder exige revisão e outros controles. [CISA, alerta AA20-352A](https://content.govdelivery.com/accounts/USDHSCISA/bulletins/2b1b32d).
