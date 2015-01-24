package org.xmf.utils

import java.lang.annotation.Annotation
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.Declaration
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference

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
	
	@Pure
	static final def String getModelFactoryName(NamedElement element) {
		val pkg = element.compilationUnit.packageName
		return '''«pkg».«pkg.stringAfterLastDot.toFirstUpper»Factory'''
	}

	@Pure
	static final def getModelPackageName(NamedElement element) {
		val pkg = element.compilationUnit.packageName
		return '''«pkg».«pkg.stringAfterLastDot.toFirstUpper»Package'''
	}
	
	@Pure
	static final def getStringAfterLastDot(String javaPackageName) {
		javaPackageName.replaceFirst(".*\\.([^.]+)$", "$1")
	}

	@Pure
	static final def getValidatorName(TypeDeclaration declaration) {
		declaration.qualifiedName + "Validator"
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
}