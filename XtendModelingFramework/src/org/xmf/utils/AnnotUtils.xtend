package org.xmf.utils

import java.lang.annotation.Annotation
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Declaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.xmf.annot.DerivedAttribute

abstract class AnnotUtils {

	@Pure static final def String toGetterName(String identifier) '''get«identifier.toFirstUpper»'''
	@Pure static final def String toGetterName(Declaration d) {d.simpleName.toGetterName}

	@Pure static final def String toSetterName(String identifier) '''set«identifier.toFirstUpper»'''
	@Pure static final def String toSetterName(Declaration d) {d.simpleName.toSetterName}

	@Pure static final def String toEDEFAULT(MemberDeclaration d) '''«d.toConstantName»_EDEFAULT'''
	@Pure static final def String toGlobalFeatureIdConst(MemberDeclaration d) {
		val cls = d.declaringType
		return cls.modelPackageName + "." + cls.toConstantName + "__" + d.toConstantName
	}
	
	@Pure static final dispatch def toTypeName(FieldDeclaration field) {field.type.name}
	@Pure static final dispatch def toTypeName(MethodDeclaration method) {method.returnType.name}

	@Pure static final dispatch def toType(FieldDeclaration field) {field.type}
	@Pure static final dispatch def toType(MethodDeclaration method) {method.returnType}

	@Pure
	static final def String getModelFactoryName(AnnotationTarget target) {
		val pkg = target.getJavaPackageName
		return '''«pkg».«pkg.stringAfterLastDot.toFirstUpper»Factory'''
	}

	@Pure @Deprecated
	static final def String getModelPackageName(AnnotationTarget target) {
		val pkg = target.getJavaPackageName
		return '''«pkg».«pkg.stringAfterLastDot.toFirstUpper»Package'''
	}
	
	@Pure @Deprecated
	static final def getModelPackageName(TypeDeclaration cls) {
		val packageName = cls.compilationUnit.packageName
		return '''«packageName».«packageName.toFirstUpper»Package'''
	}

	@Pure @Deprecated
	static final private def getJavaPackageName(AnnotationTarget target) {
		target.compilationUnit.packageName
	}
	
	@Pure
	static final def getStringAfterLastDot(String javaPackageName) {
		javaPackageName.replaceFirst(".*\\.([^.]+)$", "$1")
	}


	@Pure
	static final def getValidatorName(TypeDeclaration classDeclaration) {
		classDeclaration.qualifiedName + "Validator"
	}
	
	@Pure
	static final def toConstantName(String identifier) {
		identifier.replaceAll("([a-z])([A-Z])", "$1_$2").toUpperCase
	}

	@Pure
	static final def toConstantName(Declaration declaration) {
		declaration.simpleName.toConstantName
	}
	
	@Pure
	static final def toHumanReadable(String identifier) {
		identifier
			.replaceAll("([a-z])([A-Z])", "$1 $2") // add spaces to CamelCase
			.replaceAll("[^a-zA-Z0-9]", " ") // convert non-alphanumerals to spaces
			.split(" +").map[toFirstUpper].join(" ")
	}

	@Pure
	static final def toHumanReadable(NamedElement element) {
		element.simpleName.toHumanReadable
	}

	@Pure
	static final def toHumanReadable(TypeReference typeRef) {
		typeRef.type.simpleName.toHumanReadable
	}
	
	
	@Pure //TODO: change comparison of qualified names (Strings) to comparison of objects
	static final def getAnnotation(AnnotationTarget target, Class<? extends Annotation> annotToFind) {
		target.annotations.findFirst[annotationTypeDeclaration.qualifiedName == annotToFind.name]
	}
	
	@Pure
	static final def hasAnnotation(AnnotationTarget target, Class<? extends Annotation> annotToFind) {
		target.getAnnotation(annotToFind) != null
	}
	
	@Pure
	static final def getMembersAnnotatedBy(TypeDeclaration type, Class<? extends Annotation> annotToFind) {
		type.declaredMembers.filter[hasAnnotation(annotToFind)]
	}
	
	@Pure
	static final def getSupportedFeatures(ClassDeclaration cls) {
		return	cls.declaredFields +
				cls.declaredMethods.filter[hasAnnotation(DerivedAttribute)]
	}
	
}