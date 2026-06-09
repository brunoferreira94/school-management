# CS0118, aliases e nullability em testes xUnit

## Best Practices

1. CS0118 normalmente indica uso de um nome como tipo/membro quando ele resolve para namespace ou outro símbolo; corrija com nome totalmente qualificado ou alias explícito.
2. Use aliases com using para conflitos recorrentes de nomes entre namespace e tipo, mantendo legibilidade no teste.
3. Em warnings de nulidade, prefira corrigir fluxo/contrato (guard clauses e tipos corretos) em vez de suprimir com null-forgiving sem necessidade.
4. Para Assert.Single em coleção potencialmente nula, garanta não nulidade antes da chamada para satisfazer o compilador e manter teste claro.

## Example

```csharp
using EnrollmentDtos = SchoolManagement.Application.Contracts.Enrollment;

// Exemplo de prevenção de warning de nulidade com Assert.Single
var maybeItems = result?.Items;
Assert.NotNull(maybeItems);
var items = maybeItems!; // opcional após Assert.NotNull; pode ser evitado com helper anotado
var single = Assert.Single(items);
```

## References

1. Compiler Error CS0118  
   https://learn.microsoft.com/dotnet/csharp/misc/cs0118

2. using directive (C# Reference)  
   https://learn.microsoft.com/dotnet/csharp/language-reference/keywords/using-directive

3. :: operator - namespace alias qualifier  
   https://learn.microsoft.com/dotnet/csharp/language-reference/operators/namespace-alias-qualifier

4. Nullable reference types (C# reference)  
   https://learn.microsoft.com/dotnet/csharp/nullable-references

5. Resolve nullable warnings  
   https://learn.microsoft.com/dotnet/csharp/language-reference/compiler-messages/nullable-warnings

6. Attributes for null-state static analysis  
   https://learn.microsoft.com/dotnet/csharp/language-reference/attributes/nullable-analysis
