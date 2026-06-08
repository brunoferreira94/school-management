# 🤝 Guia de Contribuição

> Como contribuir com o projeto School Management SaaS.

---

## Índice

- [Código de Conduta](#código-de-conduta)
- [Como Contribuir](#como-contribuir)
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Padrões de Código](#padrões-de-código)
- [Commits](#commits)
- [Pull Requests](#pull-requests)
- [Testes](#testes)
- [Documentação](#documentação)

---

## Código de Conduta

- Seja respeitoso e inclusivo
- Aceite críticas construtivas
- Foque no que é melhor para o projeto
- Mostre empatia com outros contribuidores

---

## Como Contribuir

1. **Fork** o repositório
2. **Clone** seu fork localmente
3. Crie uma **branch** a partir de `development`
4. Faça suas alterações seguindo os padrões
5. Escreva **testes** para novas funcionalidades
6. Abra um **Pull Request** para `development`

---

## Configuração do Ambiente

### Pré-requisitos

| Ferramenta | Versão | Download |
|------------|--------|----------|
| .NET SDK | 8.0+ | [dotnet.microsoft.com](https://dotnet.microsoft.com/download) |
| Node.js | 18+ | [nodejs.org](https://nodejs.org/) |
| npm | 9+ | Incluído com Node.js |
| Docker | 24+ | [docker.com](https://www.docker.com/) |
| PostgreSQL | 16 | [postgresql.org](https://www.postgresql.org/) |

### Backend

```bash
# Clone
git clone https://github.com/brunoferreira94/school-management-api.git
cd school-management-api

# Restaurar
dotnet restore

# Configurar banco
# Edite ConnectionStrings__DefaultConnection em appsettings.Development.json

# Migrar banco
dotnet ef database update --project src/SchoolManagement

# Executar
dotnet run --project src/SchoolManagement

# Testes
dotnet test
```

### Frontend

```bash
# Clone
git clone https://github.com/brunoferreira94/school-management-ui.git
cd school-management-ui

# Instalar
npm ci

# Executar
npm start

# Testes unitários
npm run test

# Testes E2E
npm run e2e:open

# Lint
npm run lint

# Build
npm run build
```

---

## Padrões de Código

### Backend (.NET)

#### Nomenclatura

```csharp
// Classes — PascalCase
public class Student { }

// Métodos — PascalCase
public async Task<StudentDto> GetByIdAsync(Guid id) { }

// Propriedades — PascalCase
public string Name { get; set; }

// Campos privados — _camelCase
private readonly IRepository<Student> _repository;

// Variáveis locais — camelCase
var student = await _repository.GetByIdAsync(id);

// Constantes — PascalCase
public const int MaxPageSize = 100;
```

#### Estrutura de Arquivos

```
FeatureName/
├── Commands/
│   ├── CreateFeatureName/
│   │   ├── CreateFeatureNameCommand.cs
│   │   └── CreateFeatureNameHandler.cs
│   └── UpdateFeatureName/
│       ├── UpdateFeatureNameCommand.cs
│       └── UpdateFeatureNameHandler.cs
├── Queries/
│   ├── GetFeatureNameById/
│   │   ├── GetFeatureNameByIdQuery.cs
│   │   └── GetFeatureNameByIdHandler.cs
│   └── ListFeatureNames/
│       ├── ListFeatureNamesQuery.cs
│       └── ListFeatureNamesHandler.cs
└── DTOs/
    ├── FeatureNameDto.cs
    └── CreateFeatureNameDto.cs
```

#### CQRS Pattern

```csharp
// Command
public record CreateStudentCommand(
    string Cpf, 
    string Name, 
    DateTime BirthDate
) : ICommand<StudentDto>;

public class CreateStudentHandler 
    : ICommandHandler<CreateStudentCommand, StudentDto>
{
    private readonly IRepository<Student> _repository;
    
    public CreateStudentHandler(IRepository<Student> repository)
    {
        _repository = repository;
    }
    
    public async Task<StudentDto> HandleAsync(
        CreateStudentCommand command,
        CancellationToken ct = default)
    {
        var student = new Student(command.Cpf, command.Name, command.BirthDate);
        await _repository.AddAsync(student, ct);
        return student.ToDto();
    }
}

// Query
public record GetStudentByIdQuery(Guid Id) : IQuery<StudentDto?>;

public class GetStudentByIdHandler 
    : IQueryHandler<GetStudentByIdQuery, StudentDto?>
{
    private readonly IRepository<Student> _repository;
    
    public async Task<StudentDto?> HandleAsync(
        GetStudentByIdQuery query,
        CancellationToken ct = default)
    {
        var student = await _repository.GetByIdAsync(query.Id, ct);
        return student?.ToDto();
    }
}
```

#### Controller Pattern

```csharp
[ApiController]
[Route("api/[controller]")]
public class StudentsController : ControllerBase
{
    private readonly IQueryMediator _queryMediator;
    private readonly ICommandMediator _commandMediator;

    [HttpGet("{id:guid}")]
    [Authorize(Policy = "Permission:students.read")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var result = await _queryMediator.QueryAsync(new GetStudentByIdQuery(id));
        return result is null ? NotFound() : Ok(result);
    }

    [HttpPost]
    [Authorize(Policy = "Permission:students.write")]
    public async Task<IActionResult> Create([FromBody] CreateStudentCommand command)
    {
        var result = await _commandMediator.ExecuteAsync(command);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }
}
```

### Frontend (Angular/TypeScript)

#### Nomenclatura

```typescript
// Classes — PascalCase
class StudentService { }

// Métodos — camelCase
getStudents(): Observable<Student[]> { }

// Propriedades — camelCase
private readonly apiUrl = '';

// Constantes — UPPER_SNAKE_CASE
const MAX_PAGE_SIZE = 100;

// Interfaces — PascalCase (sem prefixo I)
interface Student { }

// Enums — PascalCase
enum StudentStatus { Active, Inactive }

// Signals — camelCase + Signal suffix (opcional)
const students = signal<Student[]>([]);
const loading = signal(false);
```

#### Component Pattern

```typescript
@Component({
  selector: 'app-student-list',
  standalone: true,
  imports: [CommonModule, RouterLink, LoadingComponent, PaginatorComponent],
  templateUrl: './student-list.component.html',
  styleUrls: ['./student-list.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class StudentListComponent implements OnInit {
  private readonly studentService = inject(StudentService);
  private readonly toast = inject(ToastService);
  private readonly confirm = inject(ConfirmService);

  // State
  students = signal<Student[]>([]);
  loading = signal(false);
  page = signal(1);
  total = signal(0);

  // Computed
  hasStudents = computed(() => this.students().length > 0);
  totalPages = computed(() => Math.ceil(this.total() / PAGE_SIZE));

  ngOnInit(): void {
    this.loadStudents();
  }

  async loadStudents(): Promise<void> {
    this.loading.set(true);
    try {
      const result = await this.studentService.getAll({ page: this.page() });
      this.students.set(result.items);
      this.total.set(result.total);
    } catch (err) {
      this.toast.error('COMMON.ERROR_LOADING');
    } finally {
      this.loading.set(false);
    }
  }

  async deleteStudent(id: string): Promise<void> {
    const confirmed = await this.confirm.confirm('COMMON.CONFIRM_DELETE');
    if (!confirmed) return;
    
    await this.studentService.delete(id);
    this.students.update(list => list.filter(s => s.id !== id));
    this.toast.success('COMMON.DELETE_SUCCESS');
  }
}
```

#### Service Pattern

```typescript
@Injectable({ providedIn: 'root' })
export class StudentService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/students`;

  getAll(params?: PaginationParams): Observable<Paginated<Student>> {
    let httpParams = new HttpParams()
      .set('page', String(params?.page ?? 1))
      .set('pageSize', String(params?.pageSize ?? 20));
    
    if (params?.search) {
      httpParams = httpParams.set('search', params.search);
    }
    
    return this.http.get<Paginated<Student>>(this.apiUrl, { params: httpParams })
      .pipe(catchError(this.handleError));
  }

  getById(id: string): Observable<Student> {
    return this.http.get<Student>(`${this.apiUrl}/${id}`)
      .pipe(catchError(this.handleError));
  }

  create(dto: CreateStudentDto): Observable<Student> {
    return this.http.post<Student>(this.apiUrl, dto)
      .pipe(catchError(this.handleError));
  }

  update(id: string, dto: UpdateStudentDto): Observable<Student> {
    return this.http.put<Student>(`${this.apiUrl}/${id}`, dto)
      .pipe(catchError(this.handleError));
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`)
      .pipe(catchError(this.handleError));
  }

  private handleError(err: HttpErrorResponse): Observable<never> {
    // Error handling logic
    return throwError(() => err);
  }
}
```

#### Template Pattern

```html
<!-- Loading state -->
@if (loading()) {
  <app-loading />
}

<!-- Empty state -->
@else if (hasStudents() === false) {
  <div class="empty-state">
    <mat-icon class="empty-state__icon">school</mat-icon>
    <p class="empty-state__title">{{ 'STUDENTS.NO_STUDENTS' | translate }}</p>
    <button class="btn btn-primary" (click)="createStudent()">
      {{ 'STUDENTS.NEW_STUDENT' | translate }}
    </button>
  </div>
}

<!-- Data -->
@else {
  <div class="table-wrapper">
    <table>
      <thead>
        <tr>
          <th>{{ 'STUDENTS.NAME' | translate }}</th>
          <th>{{ 'STUDENTS.CPF' | translate }}</th>
          <th>{{ 'STUDENTS.STATUS' | translate }}</th>
          <th>{{ 'COMMON.ACTIONS' | translate }}</th>
        </tr>
      </thead>
      <tbody>
        @for (student of students(); track student.id) {
          <tr>
            <td>{{ student.name }}</td>
            <td>{{ student.cpf | cpf }}</td>
            <td>
              <span class="badge" [class]="'badge--' + student.status">
                {{ 'STUDENTS.' + student.status | translate }}
              </span>
            </td>
            <td>
              <button (click)="editStudent(student.id)" [attr.aria-label]="'COMMON.EDIT' | translate">
                <mat-icon>edit</mat-icon>
              </button>
              <button (click)="deleteStudent(student.id)" [attr.aria-label]="'COMMON.DELETE' | translate">
                <mat-icon>delete</mat-icon>
              </button>
            </td>
          </tr>
        }
      </tbody>
    </table>
  </div>
  
  <app-paginator 
    [page]="page()" 
    [totalPages]="totalPages()"
    (pageChange)="page.set($event); loadStudents()" />
}
```

---

## Commits

Seguimos o padrão **Conventional Commits**:

```
<tipo>(<escopo>): <descrição>

[corpo opcional]

[rodapé opcional]
```

### Tipos

| Tipo | Descrição |
|------|-----------|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `refactor` | Refatoração de código |
| `perf` | Melhoria de performance |
| `test` | Adição/alteração de testes |
| `docs` | Documentação |
| `style` | Formatação (sem alteração de lógica) |
| `chore` | Tarefas de build, CI, etc. |
| `revert` | Reverter commit anterior |

### Exemplos

```
feat(students): adiciona busca por CPF

fix(grades): corrige cálculo de média ponderada

refactor(auth): simplifica lógica de refresh token

perf(home): ativa OnPush no HomeComponent

test(students): adiciona testes unitários para StudentService

docs(api): atualiza documentação de endpoints de relatórios
```

---

## Pull Requests

### Template

```markdown
## Descrição
<!-- Descreva o que foi alterado e por quê -->

## Tipo de Alteração
- [ ] Nova funcionalidade
- [ ] Correção de bug
- [ ] Refatoração
- [ ] Documentação
- [ ] Testes

## Checklist
- [ ] Código segue os padrões do projeto
- [ ] Testes adicionados/atualizados
- [ ] Documentação atualizada
- [ ] Sem erros de lint
- [ ] Build passa localmente
- [ ] Testes passam localmente

## Screenshots (se aplicável)
<!-- Adicione screenshots para alterações visuais -->

## Issues Relacionadas
<!-- Link issues relacionadas: Closes #123 -->
```

### Processo

1. Abra o PR para a branch `development`
2. Preencha o template acima
3. Aguarde review de pelo menos 1 pessoa
4. CI deve passar (build + testes)
5. Após aprovação, faça squash merge

---

## Testes

### Backend

```bash
# Todos os testes
dotnet test

# Com cobertura
dotnet test --collect:"XPlat Code Coverage"

# Teste específico
dotnet test --filter "FullyQualifiedName~StudentServiceTests"

# Com verbosity
dotnet test --logger "console;verbosity=detailed"
```

### Frontend

```bash
# Testes unitários
npm run test

# Com cobertura
npm run test -- --code-coverage

# Teste específico
npm run test -- --include='**/student.service.spec.ts'

# Testes E2E
npm run e2e:open    # Interface gráfica
npm run e2e:headless # Headless
```

### Cobertura Mínima

| Tipo | Mínimo |
|------|--------|
| Unitários (Backend) | 80% |
| Unitários (Frontend) | 70% |
| Integração | Crud completo |
| E2E | Fluxos críticos |

---

## Documentação

### Quando Documentar

- ✅ Novas funcionalidades
- ✅ Alterações na API
- ✅ Mudanças na arquitetura
- ✅ Novos padrões ou convenções
- ✅ Configuração de ambiente

### Onde Documentar

| Conteúdo | Local |
|----------|-------|
| Visão geral do projeto | `README.md` |
| Arquitetura | `docs/ARCHITECTURE.md` |
| API | `school-management-api/README.md` + `docs/` |
| Frontend | `school-management-ui/README.md` + `docs/` |
| Deploy | `DEPLOY.md` |
| Contribuição | `docs/CONTRIBUTING.md` |
| Produto | `PRD.md` |

---

## Dúvidas?

Abra uma [issue](https://github.com/brunoferreira94/school-management/issues) com a label `question`.
