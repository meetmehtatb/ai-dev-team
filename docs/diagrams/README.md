# Diagrams

PNG exports of the Mermaid diagrams in the main [README](../../README.md), for slides, wikis or viewers that don't render Mermaid.

| File | Shows |
|---|---|
| `1-overview.png` | How it works in 30 seconds |
| `2-full-flow.png` | The full flow: setup, build loop, review gate, PR, fresh review |
| `3-run-sequence.png` | One run, step by step (sequence) |
| `4-agents.png` | The agents and their groups |
| `5-docker.png` | How the Docker setup fits together |
| `6-safety.png` | What the safety hook allows and blocks |

The Mermaid source in `README.md` is the source of truth. To regenerate after changing it:
```bash
npx -y @mermaid-js/mermaid-cli -i diagram.mmd -o diagram.png -b white -w 1400
```
