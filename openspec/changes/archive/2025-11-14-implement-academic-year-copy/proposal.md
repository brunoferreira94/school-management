# Implementar Cópia de Ano Letivo Completo

Autor: @brunoferreira94 + GitHub Copilot
Data: 2025-11-14
Status: ready-to-implement

## Resumo

Funcionalidade para copiar toda a configuração de um ano letivo para um novo ano, incluindo cursos, turmas, planos, eventos, avisos e configurações relevantes. Suporta modo dry-run (simulação) e cópia seletiva de entidades.

## Motivação

- **Redução de trabalho manual**: Configurar um novo ano letivo manualmente é trabalhoso e propenso a erros
- **Consistência**: Garantir que configurações importantes não sejam esquecidas
- **Agilidade**: Permitir que administradores preparem o novo ano letivo em minutos ao invés de horas
- **Flexibilidade**: Oferecer opções para copiar apenas o necessário

## Escopo

### Backend

**Entidades a serem copiadas:**

1. **ClassGroups** (Turmas) - CORE
   - Copiar estrutura (name, schoolUnitId, capacity)
   - **NÃO** copiar students (matrículas do ano anterior)
   - **NÃO** copiar schedules (horários podem mudar)
2. **Plans** (Planos financeiros) - CORE
   - Copiar todos os campos (name, courseId, value, installments, etc.)
   - Ajustar valores se solicitado (opção de reajuste percentual)
3. **Courses** (Cursos) - CORE
   - Copiar estrutura de cursos oferecidos
4. **Events** (Eventos/Calendário) - OPTIONAL
   - Copiar estrutura de eventos recorrentes (ex: provas bimestrais)
   - Ajustar datas automaticamente para o novo ano
5. **Notices** (Avisos) - OPTIONAL
   - Copiar avisos padrão (ex: regulamentos, políticas)
6. **LessonPlans** (Planos de Aula) - OPTIONAL
   - Copiar estrutura de planejamento

**Entidades NÃO copiadas:**

- **Students/StudentClass** - Matrículas são específicas do ano
- **Attendances** - Registros históricos
- **Assessments** - Avaliações são específicas do ano
- **Grades** - Notas são específicas do ano
- **ClassSchedules** - Horários podem variar
- **StudentPlans** - Vínculos financeiros específicos
- **Assignments/Submissions** - Tarefas são específicas do ano
- **Timetables** - Horários são específicos do ano

**Funcionalidades:**

1. **Dry-run (Simulação)**
   - Retorna relatório detalhado sem modificar dados
   - Lista o que será copiado
   - Identifica conflitos potenciais
2. **Cópia Transacional**
   - Usa transação de BD para garantir atomicidade
   - Rollback automático em caso de erro
3. **Opções Seletivas**
   - Permitir escolher quais entidades copiar
   - Opção de reajuste de valores de planos
4. **Métricas**
   - Instrumentar com OpenTelemetry
   - Logs estruturados da operação

### Frontend

**UI de Wizard:**

1. **Step 1: Seleção de Anos**
   - Dropdown: Ano de origem
   - Input: Nome do novo ano
   - Input: Slug do novo ano
   - DatePickers: Data início/fim
2. **Step 2: Opções de Cópia**
   - Checkboxes para selecionar entidades
   - Input opcional: % de reajuste para planos
   - Checkbox: Modo dry-run
3. **Step 3: Confirmação/Preview**
   - Exibir relatório do dry-run
   - Botão para confirmar cópia real
4. **Step 4: Resultado**
   - Exibir progresso
   - Exibir resumo da cópia
   - Links para entidades criadas

## Critérios de Aceitação

### Backend - Aceitação

- [ ] Endpoint POST `/api/academic-years/{id}/copy` implementado
- [ ] Suporta parâmetro `dryRun=true` para simulação
- [ ] Suporta body com opções de cópia seletiva
- [ ] Retorna relatório detalhado (quantidades, IDs criados, erros)
- [ ] Usa transação de BD (rollback em caso de erro)
- [ ] Valida que ano de origem existe e está ativo/completado
- [ ] Valida que ano de destino não existe (slug único)
- [ ] Logs estruturados de toda operação
- [ ] Métricas de duração e sucesso/erro
- [ ] Testes de integração cobrindo cenários principais

### Frontend - Aceitação

- [ ] Wizard de 4 passos implementado
- [ ] Integração com endpoint de dry-run
- [ ] Exibição de relatório de preview
- [ ] Feedback visual de progresso
- [ ] Tratamento de erros com mensagens claras
- [ ] Testes unitários dos componentes

## Modelo de Dados

### Request (CopyAcademicYearRequest)

```csharp
public class CopyAcademicYearRequest
{
    public required string TargetName { get; set; }
    public required string TargetSlug { get; set; }
    public required DateTime TargetStartsOn { get; set; }
    public required DateTime TargetEndsOn { get; set; }
    public required CopyOptions Options { get; set; }
}

public class CopyOptions
{
    public bool CopyClassGroups { get; set; } = true;
    public bool CopyPlans { get; set; } = true;
    public bool CopyCourses { get; set; } = true;
    public bool CopyEvents { get; set; } = false;
    public bool CopyNotices { get; set; } = false;
    public bool CopyLessonPlans { get; set; } = false;
    public decimal? PlanValueAdjustmentPercent { get; set; } // Ex: 10 = +10%
}
```

### Response (CopyAcademicYearResponse)

```csharp
public class CopyAcademicYearResponse
{
    public bool IsDryRun { get; set; }
    public bool Success { get; set; }
    public string? ErrorMessage { get; set; }
    public Guid? NewAcademicYearId { get; set; }
    public CopyStatistics Statistics { get; set; } = new();
    public List<string> Warnings { get; set; } = new();
}

public class CopyStatistics
{
    public int ClassGroupsCopied { get; set; }
    public int PlansCopied { get; set; }
    public int CoursesCopied { get; set; }
    public int EventsCopied { get; set; }
    public int NoticesCopied { get; set; }
    public int LessonPlansCopied { get; set; }
    public TimeSpan Duration { get; set; }
}
```

## Implementação Técnica

### Backend Architecture

```text
CopyAcademicYearUseCase
├── ValidateSourceAcademicYear
├── ValidateTargetAcademicYear (slug não existe)
├── CreateTargetAcademicYear
├── CopyClassGroups (se Options.CopyClassGroups)
├── CopyPlans (se Options.CopyPlans, com ajuste de valor)
├── CopyCourses (se Options.CopyCourses)
├── CopyEvents (se Options.CopyEvents, com ajuste de datas)
├── CopyNotices (se Options.CopyNotices)
├── CopyLessonPlans (se Options.CopyLessonPlans)
└── ReturnStatistics
```

### Transação e Rollback

```csharp
using var transaction = await _context.Database.BeginTransactionAsync();
try
{
    // Executar todas as cópias
    // ...

    if (request.Options.DryRun)
    {
        await transaction.RollbackAsync();
        return Result.Ok(response with { IsDryRun = true });
    }

    await transaction.CommitAsync();
    return Result.Ok(response);
}
catch (Exception ex)
{
    await transaction.RollbackAsync();
    return Result.Fail($"Erro ao copiar ano letivo: {ex.Message}");
}
```

## Documentação Pós-Implementação

### README.md

Adicionar seção "Cópia de Ano Letivo":

- Descrição da funcionalidade
- Fluxo de uso (dry-run → confirmação)
- Limitações conhecidas
- Troubleshooting

### API Documentation

- Swagger annotations no endpoint
- Exemplos de request/response
- Códigos de erro possíveis

## Riscos e Mitigações

| Risco                      | Impacto | Probabilidade | Mitigação                                       |
| -------------------------- | ------- | ------------- | ----------------------------------------------- |
| Timeout em grandes volumes | Alto    | Médio         | Processar em batches, considerar job assíncrono |
| Conflitos de nome/slug     | Médio   | Alto          | Validação prévia, mensagens claras              |
| Perda de dados por erro    | Alto    | Baixo         | Transação + rollback, dry-run obrigatório       |
| Performance                | Médio   | Médio         | Monitorar métricas, otimizar queries            |

## Estimativa

- **Backend**: 8-12 horas
  - Use case: 4h
  - Controller: 1h
  - Testes: 3h
  - Documentação: 2h
- **Frontend**: 6-8 horas
  - Wizard components: 4h
  - Service integration: 1h
  - Testes: 2h
  - UI/UX polish: 1h

**Total**: 14-20 horas (~2-3 dias)
