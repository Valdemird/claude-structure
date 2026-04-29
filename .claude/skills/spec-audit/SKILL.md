# Skill: Spec Audit

Audita un spec contra el código real del proyecto, delegando la exploración al subagent Architect.

## Cuándo se activa

Cuando el usuario quiere auditar un spec, menciona "auditar spec", "audit", "revisar técnicamente", "analizar spec contra el código".

## Instrucciones

### 1. Verificar que el spec existe

Lee `.claude/specs/<feature-name>.md`. Si no existe, sugiere crear uno primero.

### 2. Delegar al Architect

Usa el subagent `.claude/agents/architect.md` para la auditoría técnica.

El Architect debe:
- Leer el spec completo
- Explorar el proyecto a fondo (sin escribir código)
- Analizar: estructura, patrones, convenciones, tests, dependencias
- Encontrar archivos similares a lo que se quiere construir

### 3. El Architect enriquece el spec

Agrega la sección `## Análisis Técnico (generado por Claude)` al spec:

```markdown
---

## Análisis Técnico (generado por Claude)

### Archivos a modificar
| Archivo | Razón |
|---------|-------|

### Archivos nuevos a crear
| Archivo | Contenido |
|---------|-----------|

### Patrones del proyecto a respetar
-

### Dependencias existentes relevantes
-

### Riesgos o conflictos detectados
-

### Edge cases adicionales detectados en el código
-

### Preguntas que debes responder antes de implementar
-
```

### 4. Quality Gate — Validar auditoría

```
✅ Checklist Gate 2:
- [ ] Sección "Análisis Técnico" existe en el spec
- [ ] Al menos 1 archivo a modificar listado con ruta exacta
- [ ] Patrones del proyecto documentados (mínimo 2)
- [ ] Riesgos evaluados (puede ser "ninguno detectado" si es simple)
- [ ] Edge cases del código revisados
```

### 5. Output al developer

Muestra:
1. Resumen de hallazgos del Architect
2. ¿Hay gaps o ambigüedades importantes en el spec?
3. ¿Hay algo en el código que complica la implementación?
4. Preguntas que necesitan respuesta antes de continuar
5. Instrucción: *"Resuelve las preguntas pendientes y luego ejecuta la revisión final del spec"*

**No escribas código. Solo analiza y enriquece el spec.**
