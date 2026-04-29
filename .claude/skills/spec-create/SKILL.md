# Skill: Spec Create

Crea un spec inicial estructurado para una nueva feature, delegando al subagent Spec Writer.

## Cuándo se activa

Cuando el usuario quiere crear un spec nuevo, menciona "crear spec", "nuevo spec", "spec para", "specear", o describe una feature que quiere construir.

## Instrucciones

### 1. Preparar contexto

Lee estos archivos para contexto:
- `CLAUDE.md` — roadmap y prioridades actuales
- `.claude/specs/` — specs existentes (para consistencia de formato y evitar duplicados)

### 2. Delegar al Spec Writer

Usa el subagent `.claude/agents/spec-writer.md` para generar el spec.

Pásale:
- **Feature name**: nombre kebab-case de la feature
- **Descripción**: lo que el developer dijo que quiere
- **Contexto adicional**: info relevante del roadmap o specs existentes

### 3. Quality Gate — Validar spec creado

Antes de dar por terminado, verifica:

```
✅ Checklist Gate 1:
- [ ] Archivo creado en .claude/specs/<feature-name>.md
- [ ] Sección "Contexto" presente y no vacía
- [ ] Sección "Qué quiero" presente y clara
- [ ] Sección "Comportamiento esperado" con caso normal + edge cases
- [ ] Sección "Lo que NO debe hacer" presente
- [ ] Sección "Criterios de aceptación" con al menos 3 checkboxes
- [ ] Sección "Preguntas abiertas" documentada (puede estar vacía si no hay dudas)
```

### 4. Output al developer

Muestra:
1. El spec generado completo
2. Preguntas abiertas que necesitan respuesta
3. Instrucción: *"Responde las preguntas abiertas y luego ejecuta la auditoría técnica del spec"*

**No explores el código todavía. Solo crea el spec con lo que tienes.**
