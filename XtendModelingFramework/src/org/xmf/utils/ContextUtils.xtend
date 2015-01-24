package org.xmf.utils

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.xmf.annot.Contained
import org.xmf.annot.DerivedAttribute

import static extension org.xmf.utils.AnnotUtils.*

class ContextUtils {
	extension TransformationContext context
	val TypeReference EListType
	new(TransformationContext context) {
		this.context = context
		EListType = EList.newTypeReference
	}
	
	def toModelPackage(ClassDeclaration cls) {
		val pkg = cls.compilationUnit.packageName
		val classToFind = '''«pkg».«pkg.stringAfterLastDot.toFirstUpper»Package'''
		return classToFind.findTypeGlobally
	}
	
	/**
	 * TRUE  : EReference
	 * FALSE : EAttribute
	 */
	def boolean isRefToModelElement(MemberDeclaration member) {
		val typeRef = switch member {
			FieldDeclaration : member.type
			MethodDeclaration : member.returnType
			default: return false
		}
		
		if(typeRef.inferred)
			return false
		
		// TODO: this should only by a temporary solution
		return EObject.newTypeReference.isAssignableFrom(typeRef)
	}
	
	/**
	 * TRUE  : List<Item>	which is cardinality 0..*
	 * FALSE : Item			which is cardinality 0..1
	 */
	def boolean isListType(MemberDeclaration member) {
		val typeRef = switch member {
			FieldDeclaration : member.type
			MethodDeclaration : member.returnType
			default: return false
		}
		
		if(typeRef.inferred)
			return false
			
		return typeRef.isAssignableFrom(EListType)
	}

	/**
	 * TRUE  : EReference+Containment
	 * FALSE : EReference/EAttribute without containmner
	 */
	def isContainment(MemberDeclaration member) {
		member.hasAnnotation(Contained)
	}
	
	/**
	 * TRUE  : derived feature
	 * FALSE : normal feature
	 */
	def isDerived(MemberDeclaration member) {
		member instanceof MethodDeclaration &&
		member.hasAnnotation(DerivedAttribute)
	}
}