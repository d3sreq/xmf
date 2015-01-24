# XMF: Xtend-centric meta-model specification
Using Xtend active annotations, the following code is converted automagically into a EMF-based meta-model and API.

- aimed at programmers who are familiar with EMF
- API is generated automatically while the programer writes code in the editor
- no *.genmodel files required
- no *.ecore files required
- just plain Xtend

This project is currently just a proof-of-concept.
It only covers a very small portion of EMF.

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
