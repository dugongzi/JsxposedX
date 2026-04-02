package com.jsxposed.x

import android.annotation.SuppressLint
import android.content.pm.ApplicationInfo
import com.jsxposed.x.core.utils.log.LogX
import com.jsxposed.x.feature.hook.ModuleInterfaceParamWrapper
import com.jsxposed.x.feature.hook.lpparamProcessName
import de.robv.android.xposed.IXposedHookZygoteInit
import io.github.libxposed.api.XposedInterface
import io.github.libxposed.api.XposedModule
import io.github.libxposed.api.XposedModuleInterface
import top.sacz.xphelper.XpHelper

class NewApiHook(
    base: XposedInterface,
    param: XposedModuleInterface.ModuleLoadedParam
) : XposedModule(base, param) {

    private val mainHook = MainHook()

    init {
        instance = this
        lpparamProcessName = param.processName

        runCatching {
            val modulePath = resolveModulePathCompat()
            if (modulePath.isNotBlank()) {
                val startupParam = createStartupParam(modulePath)
                XpHelper.initZygote(startupParam)
            } else {
                LogX.w("NewApiHook", "module path is empty, skip XpHelper.initZygote")
            }
        }.onFailure {
            LogX.e("NewApiHook", "init failed: ${it.message}")
        }
    }

    @SuppressLint("DiscouragedPrivateApi")
    override fun onPackageLoaded(param: XposedModuleInterface.PackageLoadedParam) {
        super.onPackageLoaded(param)
        mainHook.handleNewApiPackageLoaded(ModuleInterfaceParamWrapper(param))
    }

    companion object {
        @Volatile
        var instance: NewApiHook? = null
    }

    private fun createStartupParam(modulePath: String): IXposedHookZygoteInit.StartupParam {
        val clazz = IXposedHookZygoteInit.StartupParam::class.java
        val constructor = clazz.getDeclaredConstructor()
        constructor.isAccessible = true
        val instance = constructor.newInstance()
        val fieldModulePath = clazz.getDeclaredField("modulePath")
        fieldModulePath.isAccessible = true
        fieldModulePath.set(instance, modulePath)
        return instance
    }

    private fun resolveModulePathCompat(): String {
        val appInfo = invokeAppInfoMethod("getModuleApplicationInfo")
            ?: invokeAppInfoMethod("getApplicationInfo")
        return appInfo?.sourceDir.orEmpty()
    }

    private fun invokeAppInfoMethod(methodName: String): ApplicationInfo? {
        return runCatching {
            val method = this::class.java.methods.firstOrNull {
                it.name == methodName && it.parameterCount == 0
            } ?: return null
            method.isAccessible = true
            method.invoke(this) as? ApplicationInfo
        }.getOrNull()
    }
}
