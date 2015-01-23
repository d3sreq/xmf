package org.xmf.annot

import com.google.common.annotations.Beta
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.impl.EPackageImpl
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.xmf.utils.AnnotUtils.*

@Beta
class ModelPackageTransformation {
	private extension TransformationContext context

	private val MutableClassDeclaration packageClass
	private val MutableClassDeclaration factoryClass
	
	new(String packageName, TransformationContext context) {
		this.context = context
		this.packageClass = packageName.findClass
		this.factoryClass = packageClass.modelFactoryName.findClass
	}
	
	def run(Iterable<MutableClassDeclaration> classes) {
		addDocComment
		addExtendsDeclaration
		addFields_NAME_URI_PREFIX
		addFields_MetaObjectIds(classes)
		addFields_MetaObjectFeatureCounts(classes)
		addFields_MetaObjectFeatures(classes)
		addFields_PrivateEClassFields(classes)
		addMethods_EClassGetters(classes)
		addField_eINSTANCE
		addField_isInited
		addMethod_init
		addMethod_getFactory
		addField_isCreated
		addMethod_createPackageContents(classes)
		addField_isInitialized
		addMethod_initializePackageContents(classes)
	}
	
	def addMethods_EClassGetters(Iterable<MutableClassDeclaration> classes) {
		for(cls : classes) {
			packageClass.addMethod(cls.toGetterName) [
				primarySourceElement = cls
				visibility = Visibility.PUBLIC
				returnType = EClass.newTypeReference
				body = '''return «cls.simpleName.toFirstLower»EClass;'''
				docComment = '''
					Returns the meta object for class '{@link «cls.qualifiedName» <em>«cls.toHumanReadable»</em>}'.
					@return the meta object for class '<em>«cls.toHumanReadable»</em>'.
					@see «cls.qualifiedName»
					@generated'''
			]
		}
	}
	
	def addFields_PrivateEClassFields(Iterable<MutableClassDeclaration> classes) {
		for(cls : classes) {
			packageClass.addField('''«cls.simpleName.toFirstLower»EClass''') [
				primarySourceElement = cls
				visibility = Visibility.PRIVATE
				type = EClass.newTypeReference
				initializer = '''null'''
				docComment = '''@generated'''
			]
		}
	}
	
	def addFields_MetaObjectFeatures(Iterable<MutableClassDeclaration> classes) {
		for(cls : classes) {
			// TODO: these are just dummy fieldIds now
			cls.supportedFeatures.forEach[ field, fieldId |
				packageClass.addField('''«cls.toConstantName»__«field.toConstantName»''') [
					primarySourceElement = field
					visibility = Visibility.PUBLIC
					static = true
					final = true
					type = primitiveInt
					initializer = ''' «fieldId» /* TODO */'''
				]
			]
		}
	}
	
	def addFields_MetaObjectFeatureCounts(Iterable<MutableClassDeclaration> classes) {
		for(cls : classes) {
			packageClass.addField(cls.toConstantName + "_FEATURE_COUNT") [
				primarySourceElement = cls
				visibility = Visibility.PUBLIC
				static = true
				final = true
				type = primitiveInt
				initializer = '''0 /* TODO */'''
				docComment = '''
					The number of structural features of the '<em>«cls.toHumanReadable»</em>' class.
					@generated
					@ordered'''
			]
		}
	}
	
	def addFields_MetaObjectIds(Iterable<MutableClassDeclaration> classes) {
		classes.forEach[ cls, classId |
			packageClass.addField(cls.toConstantName) [
				primarySourceElement = cls
				visibility = Visibility.PUBLIC
				static = true
				final = true
				type = primitiveInt
				initializer = '''«classId»'''
				docComment = '''
					The meta object id for the '{@link «cls.qualifiedName» <em>«cls.toHumanReadable»</em>}' class.
					@see «cls.qualifiedName»
					@see «packageClass.qualifiedName»#«cls.toGetterName»()
					@generated'''
			]
			
		]
	}
	
	/** ADD: public void initializePackageContents() */
	def addMethod_initializePackageContents(Iterable<MutableClassDeclaration> classes) {
		packageClass.addMethod("initializePackageContents") [
			primarySourceElement = packageClass
			visibility = Visibility.PUBLIC
			docComment = '''
				Complete the initialization of the package and its meta-model. This
				method is guarded to have no affect on any invocation but its first.
				@generated'''
			body = '''
				if (isInitialized) return;
				isInitialized = true;
				
				// Initialize package
				setName(eNAME);
				setNsPrefix(eNS_PREFIX);
				setNsURI(eNS_URI);
				
				// Create type parameters
				
				// Set bounds for type parameters
				
				// Add supertypes to classes
				// TODO
				
				// Initialize classes and features; add operations and parameters
				«FOR cls : classes»
					initEClass(«cls.simpleName.toFirstLower»EClass, «cls.simpleName».class, "«cls.simpleName»", «cls.abstract.Q»IS_ABSTRACT, !IS_INTERFACE, IS_GENERATED_INSTANCE_CLASS);
					// TODO: here should be a list of features
«««					initEReference(getUser_Group(), this.getGroup(), this.getGroup_Users(), "group", null, 0, 1, User.class, !IS_TRANSIENT, !IS_VOLATILE, IS_CHANGEABLE, !IS_COMPOSITE, !IS_RESOLVE_PROXIES, !IS_UNSETTABLE, IS_UNIQUE, !IS_DERIVED, IS_ORDERED);
«««					initEAttribute(getUser_Name(), ecorePackage.getEString(), "name", null, 0, 1, User.class, !IS_TRANSIENT, !IS_VOLATILE, IS_CHANGEABLE, !IS_UNSETTABLE, IS_ID, IS_UNIQUE, !IS_DERIVED, IS_ORDERED);
				«ENDFOR»
				
				// Create resource
				createResource(eNS_URI);
			'''
		]
	}
	
	private def Q(boolean x) {
		if(x) return "" else "!"
	}
	
	/** ADD: private boolean isInitialized = false; */
	def addField_isInitialized() {
		packageClass.addField("isInitialized") [
			primarySourceElement = packageClass
			visibility = Visibility.PRIVATE
			type = primitiveBoolean
			docComment = '''@generated'''
			initializer = '''false'''
		]
	}
	
	def addMethod_createPackageContents(Iterable<MutableClassDeclaration> classes) {
		// ADD: public void createPackageContents() {...}
		packageClass.addMethod("createPackageContents") [
			primarySourceElement = packageClass
			visibility = Visibility.PUBLIC
			docComment = '''
				Creates the meta-model objects for the package.  This method is
				guarded to have no affect on any invocation but its first.
				@generated'''
			body = '''
				if (isCreated) return;
				isCreated = true;
				
				// Create non-abstract classes and their features
				«FOR cls : classes.filter[!abstract]»
					«cls.simpleName.toFirstLower»EClass = createEClass(«cls.toConstantName»);
					// TODO: here should be a list of features
«««					createEReference(userEClass, USER__GROUP);
«««					createEAttribute(userEClass, USER__NAME);
				«ENDFOR»
			'''
		]
	}
	
	/** ADD: private boolean isCreated = false; */
	def addField_isCreated() {
		packageClass.addField("isCreated") [
			primarySourceElement = packageClass
			visibility = Visibility.PRIVATE
			type = primitiveBoolean
			docComment = '''@generated'''
			initializer = '''false'''
		]
	}
	
	/** ADD: get...Factory() {...} */
	def addMethod_getFactory() {
		packageClass.addMethod(factoryClass.toGetterName) [
			primarySourceElement = packageClass
			visibility = Visibility.PUBLIC
			returnType = factoryClass.newTypeReference
			docComment = '''
				Returns the factory that creates the instances of the model.
				@return the factory that creates the instances of the model.
				@generated'''
			body = '''return («factoryClass») getEFactoryInstance();'''
		]
	}
	
	/** ADD: def static ... init() {...} */
	def addMethod_init() {
		packageClass.addMethod("init") [
			primarySourceElement = packageClass
			static = true
			visibility = Visibility.PRIVATE
			returnType = packageClass.newTypeReference
			docComment = '''
				Creates, registers, and initializes the <b>Package</b> for this model,
				and for any others upon which it depends.
				
				<p>This method is used to initialize {@link «packageClass.qualifiedName»#eINSTANCE} when that field is accessed.
				Clients should not invoke it directly. Instead, they should simply access that field to obtain the package.
				@see #eNS_URI
				@see #createPackageContents()
				@see #initializePackageContents()
				@generated'''
			body = '''return null;'''
		]
	}
	
	/** ADD: static var isInited = false */
	def addField_isInited() {
		packageClass.addField("isInited") [
			primarySourceElement = packageClass
			visibility = Visibility.PRIVATE
			static = true
			type = primitiveBoolean
			docComment = '''@generated'''
			initializer = '''false'''
		]
	}
	
	/** ADD: public static final ... eINSTANCE = init(); */
	def addField_eINSTANCE() {
		packageClass.addField("eINSTANCE") [
			primarySourceElement = packageClass
			visibility = Visibility.PUBLIC
			final = true
			static = true
			type = packageClass.newTypeReference
			docComment = '''
				The singleton instance of the package.
				@generated'''
			initializer = '''init()'''
		]
	}
	
	def addFields_NAME_URI_PREFIX() {
		val eNAME = packageClass.simpleName.replaceFirst("Package$", "").toFirstLower
		val eNS_URI = packageClass.annotations.map[it.getStringValue("value")].head
		val eNS_PREFIX = eNAME 

		// ADD: public static final String eNAME = "...";
		packageClass.addField("eNAME") [
			primarySourceElement = packageClass
			visibility = Visibility.PUBLIC
			final = true
			static = true
			type = string
			docComment = '''
				The package name.
				@generated'''
			initializer = '''"«eNAME»"'''
		]

		// ADD: public static final String eNS_URI = "...";
		packageClass.addField("eNS_URI") [
			primarySourceElement = packageClass
			visibility = Visibility.PUBLIC
			final = true
			static = true
			type = string
			docComment = '''
				The package namespace URI.
				@generated'''
			initializer = '''"«eNS_URI»"'''
		]

		// ADD:	public static final String eNS_PREFIX = "...";
		packageClass.addField("eNS_PREFIX") [
			primarySourceElement = packageClass
			visibility = Visibility.PUBLIC
			final = true
			static = true
			type = string
			docComment = '''
				The package namespace name.
				Generated from @Package( prefix=... )
				@generated'''
			initializer = '''"«eNS_PREFIX»"'''
		]
	}
	
	/** ADD: class ... extends EPackageImpl */
	def addExtendsDeclaration() {
		packageClass.extendedClass = EPackageImpl.newTypeReference
	}
	
	def addDocComment() {
		packageClass.docComment = '''
			The <b>Package</b> for the model.
			It contains accessors for the meta objects to represent
			<ul>
			  <li>each class,</li>
			  <li>each feature of each class,</li>
			  <li>each enum,</li>
			  <li>and each data type</li>
			</ul>
			@see «packageClass.qualifiedName»
			@model kind="package"
			@generated'''
	}
	
}
