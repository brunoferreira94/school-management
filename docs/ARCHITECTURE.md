# 🏗️ Guia de Arquitetura

> Visão geral da arquitetura do sistema School Management SaaS.

---

## Índice

- [Visão Geral](#visão-geral)
- [Backend](#backend)
  - [Clean Architecture](#clean-architecture)
  - [CQRS com LiteBus](#cqrs-com-litebus)
  - [Domain Events](#domain-events)
  - [Repository Pattern](#repository-pattern)
- [Frontend](#frontend)
  - [Estrutura de Módulos](#estrutura-de-módulos)
  - [Padrões de Componentes](#padrões-de-componentes)
  - [Gerenciamento de Estado](#gerenciamento-de-estado)
  - [Autenticação e Autorização](#autenticação-e-autorização)
- [Infraestrutura](#infraestrutura)
- [Fluxo de Dados](#fluxo-de-dados)

---

## Visão Geral

O sistema segue uma arquitetura **multi-tenant** com separação clara entre backend e frontend, comunicando-se via REST API com autenticação JWT.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT (Browser)                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Angular 17 SPA                                │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │  Core    │  │ Features │  │ Shared   │  │ Services │            │   │
│  │  │ (Auth,   │  │ (Home,   │  │ (UI      │  │ (HTTP,   │            │   │
│  │  │ Guards,  │  │ Students,│  │ Compo-   │  │ State,   │            │   │
│  │  │ Interc.) │  │ Reports) │  │ nents)   │  │ i18n)    │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │ HTTPS / REST API / JWT
┌─────────────────────────────────▼───────────────────────────────────────────┐
│                           NGINX (Reverse Proxy)                             │
│                        SSL Termination + Rate Limit                         │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────────────────────┐
│                         ASP.NET Core 8 API                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     Controllers (58 controllers)                     │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │ Students │  │ Teachers │  │  Reports │  │  Auth    │  ...       │   │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘            │   │
│  └───────┼──────────────┼──────────────┼─────────────┼──────────────────┘   │
│          │              │              │             │                       │
│  ┌───────▼──────────────▼──────────────▼─────────────▼──────────────────┐   │
│  │                     Application Layer (CQRS)                          │   │
│  │  ┌─────────────────────┐  ┌─────────────────────┐                    │   │
│  │  │      Commands       │  │       Queries       │                    │   │
│  │  │  (CreateStudent,    │  │  (GetStudentById,   │                    │   │
│  │  │   UpdateGrade)      │  │   ListStudents)     │                    │   │
│  │  └──────────┬──────────┘  └──────────┬──────────┘                    │   │
│  └─────────────┼────────────────────────┼───────────────────────────────┘   │
│                │                        │                                    │
│  ┌─────────────▼────────────────────────▼───────────────────────────────┐   │
│  │                          Domain Layer                                 │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │ Entities │  │ Value    │  │ Domain   │  │ Repository│            │   │
│  │  │          │  │ Objects  │  │ Events   │  │ Contracts │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘            │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                │                                                             │
│  ┌─────────────▼────────────────────────────────────────────────────────┐   │
│  │                       Infrastructure Layer                            │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │ EF Core  │  │ Repos    │  │ External │  │ Migra-   │            │   │
│  │  │ DbContext│  │ Implem.  │  │ Services │  │ tions    │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘            │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────────────────────┐
│                              PostgreSQL 16                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │ Students │  │ Teachers │  │  Grades  │  │  Plans   │  │  ...     │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Backend

### Clean Architecture

O backend segue a **Clean Architecture** com 4 camadas bem definidas:

```
src/
├── SchoolManagement.Domain/          # Camada de Domínio
│   ├── Entities/                     # Entidades e agregados
│   ├── ValueObjects/                 # Objetos de valor
│   ├── Events/                       # Domain events
│   └── Interfaces/                   # Contratos de repositório
│
├── SchoolManagement.Application/     # Camada de Aplicação
│   ├── Commands/                     # Comandos (LiteBus)
│   ├── Queries/                      # Queries (LiteBus)
│   ├── DTOs/                         # Data Transfer Objects
│   └── Interfaces/                   # Contratos de serviços
│
├── SchoolManagement.Infrastructure/  # Camada de Infraestrutura
│   ├── Data/                         # DbContext, configurações EF
│   ├── Repositories/                 # Implementação de repositórios
│   ├── Services/                     # Serviços externos
│   └── Migrations/                   # Migrações do banco
│
└── SchoolManagement/                 # Camada de Apresentação (API)
    ├── Controllers/                  # Controllers REST
    ├── Middlewares/                  # Middlewares customizados
    └── Program.cs                    # Configuração da aplicação
```

### CQRS com LiteBus

O padrão **CQRS** (Command Query Responsibility Segregation) é implementado via **LiteBus**:

```csharp
// Command — altera estado
public record CreateStudentCommand(string Cpf, string Name) : ICommand<StudentDto>;

public class CreateStudentHandler : ICommandHandler<CreateStudentCommand, StudentDto>
{
    public async Task<StudentDto> HandleAsync(CreateStudentCommand command)
    {
        // Lógica de criação
    }
}

// Query — apenas leitura
public record GetStudentByIdQuery(Guid Id) : IQuery<StudentDto>;

public class GetStudentByIdHandler : IQueryHandler<GetStudentByIdQuery, StudentDto>
{
    public async Task<StudentDto> HandleAsync(GetStudentByIdQuery query)
    {
        // Lógica de consulta
    }
}

// Controller — usa IQueryMediator
[HttpPost]
public async Task<IActionResult> Create([FromBody] CreateStudentCommand command)
{
    var result = await _commandMediator.ExecuteAsync(command);
    return Ok(result);
}
```

### Domain Events

Eventos de domínio para desacoplar side effects:

```csharp
// Definição
public record StudentEnrolledEvent(Guid StudentId, Guid ClassGroup) : IDomainEvent;

// Handler
public class StudentEnrolledHandler : IDomainEventHandler<StudentEnrolledEvent>
{
    public async Task HandleAsync(StudentEnrolledEvent @event)
    {
        // Enviar notificação, atualizar contadores, etc.
    }
}
```

### Repository Pattern

Abstração de persistência via repositórios genéricos:

```csharp
// Contrato
public interface IRepository<T> where T : BaseEntity
{
    Task<T?> GetByIdAsync(Guid id);
    Task<IReadOnlyList<T>> GetAllAsync();
    Task AddAsync(T entity);
    void Update(T entity);
    void Delete(T entity);
}

// Uso no handler
public class CreateStudentHandler : ICommandHandler<CreateStudentCommand, StudentDto>
{
    private readonly IRepository<Student> _repository;
    
    public async Task<StudentDto> HandleAsync(CreateStudentCommand command)
    {
        var student = new Student(command.Cpf, command.Name);
        await _repository.AddAsync(student);
        return student.ToDto();
    }
}
```

---

## Frontend

### Estrutura de Módulos

```
src/app/
├── core/                           # Módulo Core (singleton)
│   ├── auth/                       # Autenticação (AuthService, Auth0Service)
│   ├── guards/                     # Route guards
│   ├── interceptors/               # HTTP interceptors
│   ├── services/                   # Serviços globais (LanguageService)
│   └── components/                 # Componentes globais (LanguageSelector)
│
├── features/                       # Módulos de funcionalidades
│   ├── home/                       # Dashboard
│   │   ├── ui/                     # Componentes
│   │   ├── data/                   # Serviços de dados
│   │   └── home.routes.ts          # Rotas
│   ├── students/                   # Gestão de alunos
│   ├── teachers/                   # Gestão de professores
│   ├── class-groups/               # Gestão de turmas
│   ├── grades/                     # Notas e avaliações
│   ├── attendance/                 # Frequência
│   ├── reports/                    # Relatórios
│   ├── finance/                    # Financeiro
│   ├── notices/                    # Comunicados
│   ├── pwa/                        # PWA (offline, push)
│   └── ...                         # Outros módulos
│
├── shared/                         # Módulo Shared
│   ├── components/                 # Componentes reutilizáveis
│   ├── pipes/                      # Pipes customizados
│   ├── directives/                 # Diretivas
│   └── models/                     # Modelos compartilhados
│
├── services/                       # Serviços globais
│   ├── auth.service.ts
│   ├── toast.service.ts
│   └── ...
│
├── app.component.ts                # Componente raiz
├── app.config.ts                   # Configuração da aplicação
└── app.routes.ts                   # Rotas principais
```

### Padrões de Componentes

#### Standalone Components

Todos os componentes são **standalone** (sem NgModules):

```typescript
@Component({
  selector: 'app-student-list',
  standalone: true,
  imports: [CommonModule, RouterLink, LoadingComponent],
  templateUrl: './student-list.component.html',
  styleUrls: ['./student-list.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class StudentListComponent {
  private readonly studentService = inject(StudentService);
  
  students = signal<Student[]>([]);
  loading = signal(false);
  
  ngOnInit() {
    this.loadStudents();
  }
}
```

#### Facade Pattern

Services encapsulam chamadas HTTP:

```typescript
@Injectable({ providedIn: 'root' })
export class StudentService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/students`;
  
  getAll(params?: PaginationParams): Observable<Paginated<Student>> {
    return this.http.get<Paginated<Student>>(this.apiUrl, { params });
  }
  
  getById(id: string): Observable<Student> {
    return this.http.get<Student>(`${this.apiUrl}/${id}`);
  }
  
  create(dto: CreateStudentDto): Observable<Student> {
    return this.http.post<Student>(this.apiUrl, dto);
  }
}
```

### Gerenciamento de Estado

#### Signals (Angular 17+)

Estado reativo com Signals:

```typescript
// State
private readonly _students = signal<Student[]>([]);
private readonly _loading = signal(false);
private readonly _error = signal<string | null>(null);

// Readonly accessors
students = this._students.asReadonly();
loading = this._loading.asReadonly();
error = this._error.asReadonly();

// Computed
totalStudents = computed(() => this._students().length);
activeStudents = computed(() => 
  this._students().filter(s => s.status === 'active').length
);

// Actions
addStudent(student: Student) {
  this._students.update(current => [...current, student]);
}

removeStudent(id: string) {
  this._students.update(current => current.filter(s => s.id !== id));
}
```

#### ChangeDetection.OnPush

Todos os componentes usam `OnPush` para performance:

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MyComponent {
  // Signals disparam detecção de mudança automaticamente
}
```

### Autenticação e Autorização

#### Fluxo Auth0

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Browser  │────▶│  Auth0   │────▶│   API    │
│          │◀────│  (SSO)   │◀────│  (JWT)   │
└──────────┘     └──────────┘     └──────────┘
```

#### RBAC (Role-Based Access Control)

```typescript
// Permissões via JWT claims
interface AuthRoles {
  roles: string[];        // ['admin', 'teacher']
  permissions: string[];  // ['students.read', 'grades.write']
}

// Guard de permissão
@Injectable({ providedIn: 'root' })
export class PermissionGuard {
  canActivate(route: ActivatedRouteSnapshot): boolean {
    const required = route.data['permissions'] as string[];
    return this.authService.hasAnyPermission(required);
  }
}

// Uso no template
<button *can="'students.write'">Novo Aluno</button>
```

---

## Infraestrutura

### Docker Compose

```yaml
services:
  api:
    build: ./school-management-api
    ports: ["5066:5066"]
    depends_on: [postgres]
    
  frontend:
    build: ./school-management-ui
    ports: ["80:80"]
    depends_on: [api]
    
  postgres:
    image: postgres:16
    volumes:
      - pgdata:/var/lib/postgresql/data
```

### Observabilidade

- **Prometheus** — Métricas de aplicação
- **Grafana** — Dashboards visuais
- **Serilog** — Logging estruturado
- **Health Checks** — `/health` endpoint

---

## Fluxo de Dados

### Requisição Típica

```
1. User clicks "Save Student"
       │
2. Component calls StudentService.create(dto)
       │
3. HTTP Interceptor adds JWT token
       │
4. Nginx forwards to API
       │
5. Controller validates & dispatches command
       │
6. Handler executes business logic
       │
7. Repository saves to PostgreSQL
       │
8. Response flows back to component
       │
9. Signal updates UI reactively
```
