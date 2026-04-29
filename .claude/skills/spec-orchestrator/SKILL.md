# Skill: Spec Orchestrator

Orquesta el workflow completo de spec-driven development delegando a subagents especializados.

## Cuándo se activa

Cuando el usuario quiere desarrollar una feature nueva de principio a fin, o menciona "spec workflow", "nueva feature", "desarrollar", "implementar feature".

## Workflow completo

Este skill coordina 5 fases secuenciales. Cada fase tiene un quality gate que debe pasar antes de avanzar.

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  1. CREATE   │───▶│  2. AUDIT    │───▶│  3. REVIEW   │───▶│  4. PLAN     │───▶│  5. IMPLEMENT│
│  Spec Writer │    │  Architect   │    │  Orchestrator│    │  Architect   │    │  Implementer │
│              │    │              │    │              │    │  +Ultrathink │    │              │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │                   │                   │
   ◆ Gate 1            ◆ Gate 2            ◆ Gate 3            ◆ Gate 4            ◆ Gate 5
   Spec existe         Análisis            Semáforo             Plan aprobado       Tests pasan
   + estructura        técnico             🟢 o 🟡             por developer       + type check
   válida              completo            + dev aprueba                            + lint clean
```

## Cómo usar

### Flujo completo (recomendado)
```
"Quiero desarrollar la feature de [feature-name]"
```
El orchestrator guiará cada fase, delegando al subagent correcto.

### Fase individual
```
"Crea el spec para [feature-name]"        → Delega a Spec Writer
"Audita el spec de [feature-name]"        → Delega a Architect
"Revisa el spec de [feature-name]"        → Ejecuta Review
"Genera el plan para [feature-name]"      → Delega a Architect (con ultrathink)
"Implementa la fase 2 de [feature-name]"  → Delega a Implementer
```

## Quality Gates entre fases

### Gate 1: Spec Created → Ready for Audit
- [ ] Archivo existe en `.claude/specs/<feature>.md`
- [ ] Tiene todas las secciones requeridas (Contexto, Qué quiero, Comportamiento, Criterios)
- [ ] Tiene al menos 3 criterios de aceptación
- [ ] Preguntas abiertas están documentadas

### Gate 2: Audit Complete → Ready for Review
- [ ] Sección "Análisis Técnico" existe en el spec
- [ ] Archivos a modificar/crear están listados con rutas exactas
- [ ] Patrones del proyecto están documentados
- [ ] Riesgos detectados y documentados

### Gate 3: Review Passed → Ready for Plan
- [ ] Developer ha revisado el spec
- [ ] Semáforo es 🟢 o 🟡 (no 🔴)
- [ ] Si 🟡: supuestos están documentados y developer acepta
- [ ] Preguntas bloqueantes resueltas

### Gate 4: Plan Approved → Ready for Implementation
- [ ] Plan tiene fases claras con TDD (Red/Green/Refactor)
- [ ] Cada fase tiene archivos específicos listados
- [ ] Decisiones de arquitectura documentadas con alternativas evaluadas
- [ ] Developer ha aprobado el plan explícitamente
- [ ] Rollback plan existe para cada fase

### Gate 5: Phase Complete → Ready for Next Phase
- [ ] Todos los tests de la fase pasan
- [ ] Type check limpio (`npx tsc --noEmit`)
- [ ] Lint limpio (`npx eslint --fix`)
- [ ] Sin desviaciones no reportadas del plan
- [ ] Developer da luz verde

## Protocolo de delegación

Cuando delegas a un subagent, siempre:

1. **Carga el agente correcto** de `.claude/agents/`
2. **Pasa el contexto necesario**: nombre de feature, fase actual, estado de gates
3. **Valida el output** contra los quality gates antes de avanzar
4. **Reporta al developer** el estado después de cada fase

## Manejo de errores

- Si un gate falla → reporta qué falta y pide acción al developer
- Si un subagent encuentra un blocker → escala inmediatamente
- Si el developer quiere saltar una fase → advierte los riesgos pero permite (documentando la decisión)
- Si hay conflicto entre el spec y el código → prioriza el código existente y actualiza el spec
