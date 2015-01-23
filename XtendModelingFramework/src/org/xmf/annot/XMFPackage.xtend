package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Retention
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

import static extension org.xmf.utils.AnnotUtils.*

@Beta
@Target(TYPE)
@Retention(SOURCE)
@Active(XmfPackageCompilationParticipant)
annotation XMFPackage {
	String value // eNS_URI
}

class XmfPackageCompilationParticipant implements
	RegisterGlobalsParticipant<ClassDeclaration>,
	TransformationParticipant<MutableClassDeclaration> {
		
	override doRegisterGlobals(List<? extends ClassDeclaration> classes, extension RegisterGlobalsContext context) {
		// register *Package
		classes.map[modelPackageName].toSet.forEach[registerClass]

		// register *Factory
		classes.map[modelFactoryName].toSet.forEach[registerClass]
	}
	
	override doTransform(List<? extends MutableClassDeclaration> classes, extension TransformationContext context) {
		
		// move @XMFPackage to the generated *Package class
		val XMFPackageType = XMFPackage.findTypeGlobally
		for(cls : classes) {
			val clsAnnot = cls.findAnnotation(XMFPackageType)
			val pkgClass = cls.modelPackageName.findClass
			val foundPkgAnnot = pkgClass.findAnnotation(XMFPackageType)
			if(foundPkgAnnot == null) {
				pkgClass.addAnnotation(clsAnnot)
				
				// here is the time to set the primarySourceElement fro *Package and *Factory
				pkgClass.primarySourceElement = clsAnnot
				pkgClass.modelFactoryName.findClass.primarySourceElement = clsAnnot
				 
			} else {
				cls.addError('''Multiple @«XMFPackageType.simpleName» declaration in this Java/Xtend package''')
			}
		}
		
		
	}
}