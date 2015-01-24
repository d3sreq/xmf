package org.xmf.annot.emf.impl

import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend2.lib.StringConcatenationClient

class SingleAttribute extends AbstractFeature {
	
	final static private val StringConcatenationClient ZERO = '''0'''
	
	new(MemberDeclaration sourceMember, TransformationContext context) {
		super(sourceMember, context)
	}
	
	// TODO: use the original initializer as specified by the user
	override defaultValueInitializer() {
		return switch t : featureType {
			case primitiveInt		: ZERO
			case primitiveByte		: ZERO
			case primitiveDouble	: ZERO
			case primitiveFloat		: ZERO
			case primitiveLong		: ZERO
			case primitiveShort		: ZERO
			case primitiveBoolean	: '''false'''
			default: '''null'''
		}
	}
	
	override cachedValueInitializer() '''«defaultValueConstantName»'''
	
	override getterMethod() '''return «featureVarName»;'''
	override setterMethod() '''«featureVarName» = newValue;'''
	override eGet() '''return «getterName»();'''
	override eSet() '''«setterName»((«featureType»)newValue);return;'''
	override eUnset() '''«setterName»(«defaultValueConstantName»);return;'''
	
	override eIsSet() '''
		«IF featureType.primitive»
			return «featureVarName» != «defaultValueConstantName»;
		«ELSE»
			return «defaultValueConstantName» == null ? «featureVarName» != null : !«defaultValueConstantName».equals(«featureVarName»);
		«ENDIF»
	'''
}