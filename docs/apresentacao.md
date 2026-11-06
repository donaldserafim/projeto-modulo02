# Apresentação — cinco minutos

Preparação: abrir o **Summary** da execução final de **Supply chain** para apresentar o painel de resultados. Usar o link do artifact no resumo para baixar os relatórios e consultar `manifest.json`. Usar a URL real da execução; não preencher resultados antes de a execução terminar com sucesso.

| Tempo | Mostrar | Explicar |
|---|---|---|
| 0:00–1:00 — Antes | `scenarios/Dockerfile.before`, `run-before.txt`, `vulnerability.md` e `trivy-before.png` | A imagem executava como root e o scanner encontrou o identificador real registrado no relatório. |
| 1:00–2:00 — Ataque | `scenarios/Dockerfile.tampered`, `signed-image.txt` e `tampered-image.txt` | Uma alteração inofensiva representa substituição na distribuição. Os digests são diferentes. |
| 2:00–4:00 — Depois | `policy-before.json`, `policy-after.json`, `run-after.txt`, `cosign-verify.json` e `tampered-assertion.txt` | Rego rejeita root; a imagem final usa UID 10001; Cosign aceita a identidade confiável e rejeita a variante sem assinatura. Mostrar também o SBOM e sua atestação. |
| 4:00–5:00 — Por que importa | `mapa-de-ameacas.md` e `compliance.md` | SolarWinds evidencia o risco do build comprometido, inclusive com assinatura legítima. Explicar o que os controles demonstram e seus limites. |

Frases essenciais: remover root não elimina CVEs; SBOM não corrige dependências; assinatura não garante código seguro; falha de rede não comprova bloqueio de adulteração. O workflow Supply chain fica verde quando todas as suas asserções passam, inclusive as rejeições esperadas. O CI sozinho não demonstra assinatura ou adulteração.
