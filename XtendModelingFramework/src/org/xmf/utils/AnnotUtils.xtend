package org.xmf.utils

import java.lang.annotation.Annotation
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.xmf.annot.Attribute
import org.xmf.annot.Containment
import org.xmf.annot.ID

abstract class AnnotUtils {

	@Pure static final def String toGetterName(String identifier) '''get«identifier.toFirstUpper»'''
	@Pure static final def String toSetterName(String identifier) '''set«identifier.toFirstUpper»'''

	@Pure
	static final def String getModelFactoryName(AnnotationTarget target) {
		val pkg = target.getJavaPackageName
		return '''«pkg».«pkg.stringAfterLastDot.toFirstUpper»Factory'''
	}

	@Pure
	static final def String getModelPackageName(AnnotationTarget target) {
		val pkg = target.getJavaPackageName
		return '''«pkg».«pkg.stringAfterLastDot.toFirstUpper»Package'''
	}
	
	@Pure
	static final private def getJavaPackageName(AnnotationTarget target) {
		target.compilationUnit.packageName
	}
	
	@Pure
	static final private def getStringAfterLastDot(String javaPackageName) {
		javaPackageName.replaceFirst(".*\\.([^.]+)$", "$1")
	}


	@Pure
	static final def getValidatorName(TypeDeclaration classDeclaration) {
		classDeclaration.qualifiedName + "Validator"
	}
	
	@Pure
	static final def getModelPackageName(TypeDeclaration cls) {
		val packageName = cls.compilationUnit.packageName
		return '''«packageName».«packageName.toFirstUpper»Package'''
	}
	
	@Pure @Deprecated
	static final def getModelPackageClassDeclaration(TypeDeclaration cls, extension TransformationContext context) {
		cls.modelPackageName.findClass
	}
	
	@Pure
	static final def toConstantName(String identifier) {
		identifier.replaceAll("([a-z])([A-Z])", "$1_$2").toUpperCase
	}
	
	@Pure
	static final def toHumanReadable(String identifier) {
		identifier
			.replaceAll("([a-z])([A-Z])", "$1 $2") // add spaces to CamelCase
			.replaceAll("[^a-zA-Z0-9]", " ") // convert non-alphanumerals to spaces
			.split(" +").map[toFirstUpper].join(" ")
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
	static final def getSupportedFeatures(TypeDeclaration type) {
		val fieldsWithID = type.getMembersAnnotatedBy(ID)
		val fieldsWithContainment = type.getMembersAnnotatedBy(Containment)
		val fieldsWithAttribute = type.getMembersAnnotatedBy(Attribute)
		return fieldsWithID + fieldsWithContainment + fieldsWithAttribute
	}
}