# Raio-X da Cadeia de Suprimentos

Projeto final do módulo CY-SE-013: uma aplicação shell definida no Dockerfile demonstra bloqueio de root com Rego, inventário Syft, vulnerabilidades reais com Trivy e verificação Cosign keyless contra substituição de imagem.

**Estado:** implementação preparada; execução remota, publicação e evidências ainda pendentes. Todos os testes, builds e demonstrações rodam pelo GitHub Actions. O usuário cuida do Git, dos commits, das branches, do remoto e da publicação do repositório.

## O que será demonstrado

| Antes / ataque | Controle e resultado esperado |
|---|---|
| Container com root | Política sobre a imagem real rejeita UID zero; imagem final roda como UID 10001 |
| Pacotes de uma base histórica | Syft gera SBOM e Trivy registra ao menos uma vulnerabilidade real |
| Imagem substituída por variante com arquivo marcador | Outro digest, sem assinatura confiável, é rejeitado pelo Cosign |

A mesma base histórica é usada no antes/depois para isolar o efeito de `USER`. A imagem final continua sendo de laboratório, com pacotes potencialmente vulneráveis. A assinatura confirma integridade e identidade dentro da confiança configurada, sem garantir segurança do código.

## Executar pelo GitHub Actions

1. Após o usuário disponibilizar o repositório com os workflows na branch `main`, conferir as permissões no GitHub. Actions precisa estar habilitado; a organização deve permitir `packages: write` e OIDC (`id-token: write`) no job de publicação.
2. Abrir **Actions → CI → Run workflow** para validar políticas, builds, UID, SBOM e scans; pushes e pull requests também disparam o CI.
3. Abrir **Actions → Supply chain → Run workflow**, selecionando `main`, para repetir os controles, publicar no GHCR, assinar e testar adulteração. Push na `main` também dispara esse workflow.
4. Abrir o **Summary** da execução para consultar o painel de resultados e o link do artifact. A etapa de resumo usa `always()` para executar também após falhas, enquanto o runner estiver disponível; etapas não executadas e evidências incompletas ficam identificadas.
5. Após sucesso, o usuário preserva as evidências conforme [evidence/README.md](evidence/README.md) e administra os checks obrigatórios do job `validate` no workflow CI, conforme os recursos do repositório.

Não há chaves privadas ou tokens a cadastrar no repositório: a publicação usa `GITHUB_TOKEN`, e Cosign usa a identidade OIDC da execução. As permissões de escrita e OIDC ficam no job de publicação; o CI tem somente leitura. Pull requests não publicam ou assinam imagens. A execução manual de publicação fora da `main` é ignorada.

O GHCR receberá `ghcr.io/<proprietario>/<repositorio>` e `ghcr.io/<proprietario>/<repositorio>-tampered`, em letras minúsculas, com tags únicas por commit, execução e tentativa. A visibilidade dos pacotes deve ser conferida no GitHub; as verificações do workflow usam autenticação. O nome separado para a variante mantém suas referências distintas, e os digests diferem porque seu conteúdo foi modificado.

O Cosign exige `https://token.actions.githubusercontent.com` como issuer e a identidade exata `https://github.com/<proprietario>/<repositorio>/.github/workflows/supply-chain.yml@refs/heads/main`. Não há wildcard de organização nem flags para ignorar o log de transparência. A identidade da assinatura fica registrada nos serviços públicos do Sigstore.

## Organização

- [Plano de execução](PLANO_EXECUCAO.md) e [enunciado](Projeto_Final_Curso.md).
- `Dockerfile`: variante UID 10001; `scenarios/`: root e alteração inofensiva.
- `policies/`: regra Rego v1 e testes de entradas válidas/inválidas.
- `.github/workflows/`: todos os comandos e a geração de relatórios, manifesto e Job Summary ficam diretamente nos steps dos workflows.
- `config/`: base por digest e locks de ferramentas e Actions. Syft usa `anchore/sbom-action` e Trivy usa `aquasecurity/trivy-action`, com Actions por SHA e ferramentas por versão; OPA usa `open-policy-agent/setup-opa` para executar as políticas Rego; Cosign usa `sigstore/cosign-installer`.
- [Mapa de ameaças](docs/mapa-de-ameacas.md), [compliance](docs/compliance.md) e [apresentação](docs/apresentacao.md).

A regra exige UID numérico positivo e permite grupo numérico opcional. Nomes de usuário são rejeitados porque a configuração isolada não comprova seu UID. Ela não impõe uma política sobre o GID: UID positivo com GID zero passa no controle demonstrado.

## Instalação de ferramentas no Actions

| Ferramenta | Preparação |
|---|---|
| OPA / Rego | `uses: open-policy-agent/setup-opa` |
| Syft | `uses: anchore/sbom-action` |
| Trivy | `uses: aquasecurity/trivy-action` |
| Cosign | `uses: sigstore/cosign-installer` |
| Python, Docker/Buildx, jq, Bash e Chrome | Fornecidos pela imagem do runner `ubuntu-24.04` |

Todas as instalações específicas do projeto usam Actions por SHA e ferramentas por versão. Quando uma ferramenta precisar de instalação e não tiver uma Action adequada, os comandos deverão ficar diretamente em um step `run:` do workflow, com versão e verificação de integridade quando disponível. Não há scripts próprios de instalação.

## Job Summary

Cada workflow publica um painel em `GITHUB_STEP_SUMMARY`, depois do upload das evidências, com:

- Status de instalação, testes Rego, builds, SBOMs, scans, coleta e upload.
- Comparativo antes/depois: usuário, violações Rego e componentes inventariados.
- Contagem de vulnerabilidades por severidade e ficha do achado real selecionado.
- No **Supply chain**, resultados do Cosign, referências por digest e identidade confiável.
- Link do artifact, índice dos arquivos e saídas da aplicação e dos testes em uma seção recolhível.

O painel usa os resultados dos steps e os relatórios da própria execução. Uma falha, cancelamento ou etapa ignorada permanece identificada; arquivo produzido parcialmente não significa controle aprovado. Os relatórios completos continuam no artifact.

## Ler os resultados

Uma execução verde do **CI** indica aprovação dos testes Rego, da rejeição de root e das asserções de inventário e scan. Uma execução verde de **Supply chain** inclui também assinatura, atestação e rejeição da variante sem assinatura confiável. O scan da base histórica deve encontrar ao menos um achado, mas não exige zero CVEs no resultado final. Erros de ferramentas, registry ou rede não devem contar como rejeição esperada.

O artifact inclui `opa-tests.txt`, inspeções e gates JSON, logs de UID, SBOMs, relatórios Trivy, `selected-finding.json`, ficha do achado e print do relatório. Na publicação, inclui referências por digest, saída de assinatura/verificação, atestação do SBOM e prova da rejeição. `manifest.json` registra origem, estado no momento da coleta e checksums. Referências das imagens e versões ficam nos arquivos associados; o estado posterior do upload aparece no Summary e nos logs. A retenção solicitada é de 90 dias, limitada pela configuração da conta.

Se Trivy não encontrar achados, revisar a base histórica em `config/base-image.txt` e nos três Dockerfiles e repetir no Actions após o usuário disponibilizar a alteração. Nunca inserir CVEs manualmente para fazer a asserção passar. Se o Cosign falhar por rede ou autenticação, corrigir o acesso e repetir; verificar também o diagnóstico da imagem legítima. Se a política falhar, consultar o JSON de `Config.User` e a coleção de violações.

A [matriz de correspondência com a avaliação](PLANO_EXECUCAO.md#2-correspondência-com-a-avaliação) identifica a implementação e as evidências necessárias para cada um dos cinco critérios do enunciado.

## Referências

A assinatura por identidade segue a [documentação do Sigstore](https://docs.sigstore.dev/cosign/verifying/verify/). O uso do OPA sobre dados extraídos da imagem segue a [documentação de CI/CD do OPA](https://www.openpolicyagent.org/docs/cicd). O limite da comparação com SolarWinds é explicado no [mapa de ameaças](docs/mapa-de-ameacas.md), com referência ao alerta original da CISA.
