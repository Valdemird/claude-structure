# Skill: Spec Implement

Implementa una fase específica del plan, delegando al subagent Implementer con TDD estricto.

## Cuándo se activa

Cuando el usuario quiere implementar una fase, menciona "implementar fase", "ejecutar fase", "implement", "fase 1", "fase 2", etc.

## Instrucciones

### 1. Identificar qué implementar

Extrae del input del developer:
- **Feature name**: nombre del spec
- **Fase número**: qué fase implementar

### 2. Verificar pre-requisitos

Antes de implementar, verifica:
- El spec existe en `.claude/specs/<feature>.md`
- El plan de implementación está en el spec
- Si es Fase > 1: la fase anterior fue completada

### 3. Delegar al Implementer

Usa el subagent `.claude/agents/implementer.md` para ejecutar la fase.

El Implementer sigue estrictamente:

```
1. RED — Escribir tests que fallan
   → Crear archivos de test según el plan
   → Ejecutar: npx vitest run [archivo] → debe FALLAR
   → Si pasa sin código → test mal escrito, rehacer

2. GREEN — Implementar el mínimo
   → Solo código para que tests pasen
   → Ejecutar: npx vitest run [archivo] → debe PASAR
   → Si falla → iterar (sin cambiar tests)

3. REFACTOR — Limpiar sin romper
   → Mejorar nombres, reducir duplicación
   → Ejecutar: npx vitest run [archivo] → debe SEGUIR pasando
```

### 4. Verificaciones post-fase (Quality Gate 5)

El Implementer debe ejecutar en orden:

```bash
# 1. Tests de la fase
npx vitest run --reporter=verbose [archivos-de-la-fase]

# 2. Type check
npx tsc --noEmit

# 3. Lint + fix
npx eslint [archivos-modificados] --fix

# 4. Format
npx prettier --write [archivos-modificados]

# 5. Tests completos (si afecta múltiples módulos)
npm run test
```

```
✅ Checklist Gate 5:
- [ ] Tests de la fase: todos pasan
- [ ] Type check: sin errores
- [ ] Lint: sin errores (después de --fix)
- [ ] Sin desviaciones no reportadas del plan
- [ ] Reporte post-fase generado
```

### 5. Protocolo STOP

Si el Implementer encuentra cualquiera de estas situaciones, debe PARAR:

- ⛔ El código existente contradice el plan
- ⛔ Necesita una dependencia no prevista
- ⛔ Un test existente se rompe por los cambios
- ⛔ Más archivos afectados de los previstos
- ⛔ Bug existente que afecta la implementación
- ⛔ Ambigüedad en el plan interpretable de múltiples formas

**Nunca improvises. Parar y preguntar > romper algo.**

### 6. Output al developer

```markdown
## Fase [N] — Completada ✅

### Archivos creados
- [ruta]: [descripción]

### Archivos modificados
- [ruta]: [qué cambió]

### Tests
- [X] nuevos, [Y] pasando, [Z] fallando
- Verificaciones: tsc ✅ | eslint ✅ | prettier ✅

### Decisiones tomadas
- [decisión]: [razón]

### Desviaciones del plan
- [ninguna / descripción]
```

Pregunta final:
> "Fase [N] completada. ¿Revisas el código y me das luz verde para la Fase [N+1], o hay algo que ajustar?"

**Espera revisión del developer antes de la siguiente fase.**
