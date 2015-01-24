# XMF: Xtend-centric meta-model specification
Using Xtend active annotations, the following code is converted automagically into a EMF-based meta-model and API.

- aimed at programmers who are familiar with EMF
- API is generated automatically while the programer writes code in the editor
- no *.genmodel files required
- no *.ecore files required
- just plain Xtend

This project is currently just a proof-of-concept.
It only covers a very small portion of EMF.

## Currently supported:
- `@XMFPackage` creates `EPackage` + `EFactory` classes
- `@XMF` for classes of the meta model
- inheritance using classes and abstract classes (currently no interfaces, but it will change soon)
- `@Contained` for containment relation
- `@Invariant` marks validation methods. XMF will automatically create the Validator class as necessary
- Non-XMF datatypes are treated as attributes
- XMF datatype is treated as a reference
- `@DerivedAttribute` for attributes whose value is computed in a method
- `List<T>` is treated as a attribute/reference of cardinality `0..*` and mapped to `EList<T>`
- public methods are treated as `EOperations`
- non-public method are ignored

## Example meta model:

```Xtend

@XMFPackage("http://some/eNS_URI")

@XMF abstract class NamedEntity {

	@ID String name
	
	@Invariant("name must be smaller than 10 characters")
	def nameSizeConstraint() {
		name.length < 10
	}
	
	@Invariant("name cannot be empty")
	def nameNotEmpty() {
		! name.empty
	}
}

@XMF class User extends NamedEntity {
	List<String> phones
	@OppositeOf("users") Group group
	@Contained Account userAccount
	
	def someOperation() {
		...
	}
	
	private def helperMethod() {
		...
	}
}

@XMF class Group extends NamedEntity {
	@Contained List<User> users
	@DerivedAttribute def paidUsers() {
		users.filter[salary > 0]
	}
}

@XMF class Account {
	int salary = 0
}
```
