# Skill: Spec Review

Revisión final del spec con semáforo de readiness antes de pasar a planning.

## Cuándo se activa

Cuando el usuario quiere revisar un spec antes de planificar, menciona "review spec", "revisar spec", "¿está listo el spec?", "semáforo", "readiness".

## Instrucciones

### 1. Leer el spec completo

Lee `.claude/specs/<feature-name>.md` incluyendo el Análisis Técnico si existe.

### 2. Mostrar el spec

Presenta el contenido completo del spec al developer.

### 3. Evaluar readiness — Semáforo

Evalúa cada dimensión:

**🟢 Listo (Verde):**
- Cosas bien definidas, sin ambigüedad, con criterios claros

**🟡 Puede continuar con supuestos (Amarillo):**
- Cosas ambiguas pero que se pueden asumir razonablemente
- Documenta el supuesto que harías: "Asumiría que X porque Y"

**🔴 Bloqueante (Rojo):**
- Decisiones críticas que faltan y NO se pueden asumir
- Sin esto, el plan será incorrecto

### 4. Quality Gate — Validar readiness

```
✅ Checklist Gate 3:
- [ ] Spec tiene Análisis Técnico (pasó por audit)
- [ ] No hay items 🔴 sin resolver
- [ ] Todos los 🟡 tienen supuestos documentados
- [ ] Developer ha confirmado que quiere continuar
```

### 5. Output al developer

```markdown
## Semáforo de Readiness: [feature-name]

### 🟢 Listo
- [lista de cosas bien definidas]

### 🟡 Puede continuar con supuestos
- [cosa ambigua] → Supuesto: [lo que asumiría]

### 🔴 Bloqueante
- [decisión que falta]

### Veredicto: [READY / READY CON SUPUESTOS / BLOQUEADO]
```

Pregunta final:
> "¿Quieres ajustar algo del spec o procedemos a generar el plan de implementación?"

**Espera confirmación del developer antes de avanzar.**
