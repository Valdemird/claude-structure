# Skill: Spec Plan (con Ultrathink)

Genera un plan de implementación por fases con TDD, delegando al subagent Architect con extended thinking activado.

## Cuándo se activa

Cuando el usuario quiere planificar la implementación de un spec, menciona "plan", "planificar", "generar plan", "cómo implementar".

## Instrucciones

### 1. Activar Extended Thinking (Ultrathink)

**IMPORTANTE**: Este skill requiere pensamiento profundo. Antes de generar el plan:

Piensa **muy extensamente** sobre:

#### Análisis de trade-offs
- Para cada decisión de diseño, evalúa mínimo 2 alternativas
- Documenta pros/contras de cada una
- Justifica la elección con evidencia del código existente

#### Devil's Advocate
- Argumenta **contra** tu propia propuesta
- ¿Qué asumes que podría ser falso?
- ¿Qué cambió desde que se escribió el spec que invalida algo?
- ¿Qué haría un reviewer Senior que encontrara este plan?

#### Análisis de riesgo
- ¿Qué puede fallar en cada fase?
- ¿Cuál es el blast radius si algo sale mal?
- ¿Es reversible? ¿Cuánto cuesta el rollback?

#### Deuda técnica
- ¿Estamos creando deuda técnica?
- ¿Es deuda aceptable (pragmática) o problemática (estructural)?
- ¿Hay deuda existente que esta feature empeora?

### 2. Leer el spec auditado

Lee `.claude/specs/<feature-name>.md` completo, incluyendo el Análisis Técnico.

### 3. Delegar al Architect

Usa el subagent `.claude/agents/architect.md` para generar el plan.

El Architect genera un plan con este formato:

```markdown
## Plan: [Nombre Feature]

### Análisis de trade-offs (Ultrathink)
| Decisión | Opción A | Opción B | Elegida | Razón |
|----------|----------|----------|---------|-------|

### Devil's Advocate
- [argumento contra la propuesta y por qué igual procedemos]

### Fase 1 — [Nombre descriptivo]
**Objetivo:** qué queda funcionando al terminar
**Archivos:**
- crear: [ruta exacta]
- modificar: [ruta exacta]

**TDD — Red:**
- [ ] Test: [descripción + archivo] → espera fallo ❌

**TDD — Green:**
- [ ] [código a escribir] → tests pasan ✅

**TDD — Refactor:**
- [ ] [mejoras] → tests siguen ✅

**Verificación:** [cómo validar]
**Rollback:** [cómo deshacer]

### Fase N — ...

### Decisiones de implementación
- [decisión + justificación]

### Fuera del scope
- [lo que NO se implementa]

### Riesgos
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
```

### 4. Quality Gate — Validar plan

```
✅ Checklist Gate 4:
- [ ] Plan tiene al menos 2 fases
- [ ] Cada fase tiene TDD (Red/Green/Refactor)
- [ ] Cada fase tiene archivos específicos con rutas exactas
- [ ] Tabla de trade-offs presente con alternativas evaluadas
- [ ] Sección Devil's Advocate presente y no vacía
- [ ] Riesgos documentados con mitigación
- [ ] Rollback plan en cada fase
- [ ] Sección "Fuera del scope" presente
```

### 5. Output al developer

Muestra el plan completo y pregunta:

> "¿Apruebas este plan o quieres ajustar algo antes de empezar la Fase 1?"

**No escribas código. Espera aprobación explícita del developer.**

## Reglas

- Máximo 4-5 fases para features medianas
- Cada fase verificable independientemente
- TDD estricto: tests ANTES del código
- Si hay ambigüedad, documenta el supuesto
- El plan debe ser ejecutable sin preguntas adicionales
