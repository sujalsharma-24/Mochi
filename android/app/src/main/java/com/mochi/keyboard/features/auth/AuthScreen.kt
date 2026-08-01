package com.mochi.keyboard.features.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.components.GradientButton
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiRadius
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.util.findActivity

private enum class AuthMode { SIGN_IN, SIGN_UP }
private enum class AuthMethod { EMAIL, PHONE }

private const val APPLE_NOTICE = "Apple Sign-In isn't required on Android (it's an iOS App Store rule) - not built here."

/** No Figma source — see OnboardingScreen.kt header note. Login methods per locked spec: Email +
 * Password, Google, Apple (mandatory alongside Google on iOS), Phone + OTP. No guest mode.
 *
 * Email/Password, Google, and Phone are all wired to real Firebase Auth (against the Local
 * Emulator Suite by default - see MochiApplication). Apple stays a stub - Apple Sign-In is an
 * iOS-only App Store requirement, not applicable on Android. */
@Composable
fun AuthScreen(
    modifier: Modifier = Modifier,
    onAuthenticated: () -> Unit = {},
    viewModel: AuthViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val activity = remember(context) { context.findActivity() }

    AuthScreenContent(
        modifier = modifier,
        uiState = uiState,
        onSignIn = { email, password -> viewModel.signIn(email, password, onAuthenticated) },
        onSignUp = { email, password -> viewModel.signUp(email, password, onAuthenticated) },
        onSendPasswordReset = viewModel::sendPasswordReset,
        onShowNotice = viewModel::showNotice,
        onGoogleSignIn = {
            val act = activity
            if (act != null) viewModel.signInWithGoogle(act, onAuthenticated)
            else viewModel.showNotice("Couldn't start Google Sign-In from this screen.")
        },
        onSendPhoneCode = { phoneNumber ->
            val act = activity
            if (act != null) viewModel.sendPhoneCode(phoneNumber, act, onAuthenticated)
            else viewModel.showNotice("Couldn't start phone verification from this screen.")
        },
        onVerifyPhoneCode = { code -> viewModel.verifyPhoneCode(code, onAuthenticated) },
        onResetPhoneFlow = viewModel::resetPhoneFlow
    )
}

@Composable
private fun AuthScreenContent(
    modifier: Modifier = Modifier,
    uiState: AuthUiState,
    onSignIn: (String, String) -> Unit,
    onSignUp: (String, String) -> Unit,
    onSendPasswordReset: (String) -> Unit,
    onShowNotice: (String) -> Unit,
    onGoogleSignIn: () -> Unit = {},
    onSendPhoneCode: (String) -> Unit = {},
    onVerifyPhoneCode: (String) -> Unit = {},
    onResetPhoneFlow: () -> Unit = {}
) {
    var mode by remember { mutableStateOf(AuthMode.SIGN_IN) }
    var method by remember { mutableStateOf(AuthMethod.EMAIL) }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }
    var otpCode by remember { mutableStateOf("") }
    val codeSent = uiState.phoneVerificationId != null

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(MochiSpacing.lg),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(MochiSpacing.xl))
            Text(text = "Mochi", style = MochiFont.logo(40.sp), color = MochiColor.logoSolid)
            Spacer(modifier = Modifier.height(MochiSpacing.xs))
            Text(
                text = if (mode == AuthMode.SIGN_IN) "Welcome back" else "Create your account",
                style = MochiFont.heading(16.sp),
                color = MochiColor.textSecondary
            )
            Spacer(modifier = Modifier.height(MochiSpacing.lg))

            ModeToggle(mode) { mode = it }
            Spacer(modifier = Modifier.height(MochiSpacing.lg))

            if (method == AuthMethod.EMAIL) {
                AuthTextField(value = email, onValueChange = { email = it }, placeholder = "Email address")
                Spacer(modifier = Modifier.height(MochiSpacing.sm))
                AuthTextField(value = password, onValueChange = { password = it }, placeholder = "Password", isPassword = true)

                if (mode == AuthMode.SIGN_IN) {
                    Spacer(modifier = Modifier.height(MochiSpacing.sm))
                    Text(
                        text = "Forgot password?",
                        style = MochiFont.caption(13.sp),
                        color = MochiColor.purple,
                        modifier = Modifier.fillMaxWidth().clickable {
                            if (email.isBlank()) {
                                onShowNotice("Enter your email above first.")
                            } else {
                                onSendPasswordReset(email)
                            }
                        }
                    )
                }
            } else if (!codeSent) {
                AuthTextField(
                    value = phone,
                    onValueChange = { phone = it },
                    placeholder = "Phone number (e.g. +15551234567)",
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone)
                )
            } else {
                AuthTextField(
                    value = otpCode,
                    onValueChange = { otpCode = it },
                    placeholder = "6-digit code",
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword)
                )
                Spacer(modifier = Modifier.height(MochiSpacing.sm))
                Text(
                    text = "Change number",
                    style = MochiFont.caption(13.sp),
                    color = MochiColor.purple,
                    modifier = Modifier.fillMaxWidth().clickable {
                        otpCode = ""
                        onResetPhoneFlow()
                    }
                )
            }

            if (uiState.errorMessage != null) {
                Spacer(modifier = Modifier.height(MochiSpacing.sm))
                Text(
                    text = uiState.errorMessage.orEmpty(),
                    style = MochiFont.caption(12.sp),
                    color = Color(0xFFD32F2F),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
            }
            if (uiState.resetEmailSent) {
                Spacer(modifier = Modifier.height(MochiSpacing.sm))
                Text(
                    text = "Password reset email sent - check your inbox.",
                    style = MochiFont.caption(12.sp),
                    color = MochiColor.purple,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            Spacer(modifier = Modifier.height(MochiSpacing.lg))

            GradientButton(
                title = when {
                    uiState.isLoading -> "Please wait..."
                    method == AuthMethod.PHONE && codeSent -> "Verify Code"
                    method == AuthMethod.PHONE -> "Send OTP"
                    mode == AuthMode.SIGN_IN -> "Sign In"
                    else -> "Create Account"
                },
                onClick = {
                    if (uiState.isLoading) return@GradientButton
                    when {
                        method == AuthMethod.PHONE && codeSent ->
                            if (otpCode.isBlank()) onShowNotice("Enter the code sent to your phone.") else onVerifyPhoneCode(otpCode)
                        method == AuthMethod.PHONE ->
                            if (phone.isBlank()) onShowNotice("Enter your phone number.") else onSendPhoneCode(phone)
                        email.isBlank() || password.isBlank() -> onShowNotice("Enter both email and password.")
                        mode == AuthMode.SIGN_IN -> onSignIn(email, password)
                        else -> onSignUp(email, password)
                    }
                }
            )

            Spacer(modifier = Modifier.height(MochiSpacing.md))
            DividerWithLabel(text = "or continue with")
            Spacer(modifier = Modifier.height(MochiSpacing.md))

            SocialButton(label = "Continue with Google", background = Color.White, contentColor = MochiColor.textPrimary, badge = "G", badgeColor = MochiColor.purple, onClick = onGoogleSignIn)
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            SocialButton(label = "Continue with Apple", background = MochiColor.textPrimary, contentColor = Color.White, onClick = { onShowNotice(APPLE_NOTICE) })
            Spacer(modifier = Modifier.height(MochiSpacing.sm))

            val phoneToggleLabel = if (method == AuthMethod.EMAIL) "Use phone number instead" else "Use email instead"
            Row(
                modifier = Modifier.fillMaxWidth().clickable {
                    if (method == AuthMethod.PHONE) {
                        otpCode = ""
                        onResetPhoneFlow()
                    }
                    method = if (method == AuthMethod.EMAIL) AuthMethod.PHONE else AuthMethod.EMAIL
                },
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(imageVector = Icons.Filled.Phone, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(14.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text(text = phoneToggleLabel, style = MochiFont.caption(13.sp), color = MochiColor.textSecondary)
            }

            Spacer(modifier = Modifier.weight(1f))
            Spacer(modifier = Modifier.height(MochiSpacing.lg))
            Text(
                text = "By continuing, you agree to Mochi's Terms of Service and Privacy Policy",
                style = MochiFont.caption(11.sp),
                color = MochiColor.textSecondary,
                textAlign = TextAlign.Center
            )
        }
    }
}

@Composable
private fun ModeToggle(selected: AuthMode, onSelect: (AuthMode) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.pill))
            .background(Color.White)
            .padding(4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        AuthMode.entries.forEach { entry ->
            val isSelected = entry == selected
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .then(if (isSelected) Modifier.background(MochiGradient.primaryButton) else Modifier)
                    .clickable { onSelect(entry) }
                    .padding(vertical = 10.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = if (entry == AuthMode.SIGN_IN) "Sign In" else "Sign Up",
                    style = MochiFont.button(14.sp),
                    color = MochiColor.textPrimary
                )
            }
        }
    }
}

@Composable
private fun AuthTextField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    isPassword: Boolean = false,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .padding(horizontal = MochiSpacing.md, vertical = 14.dp)
    ) {
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            textStyle = MochiFont.body(14.sp).copy(color = MochiColor.textPrimary),
            visualTransformation = if (isPassword) PasswordVisualTransformation() else androidx.compose.ui.text.input.VisualTransformation.None,
            keyboardOptions = keyboardOptions,
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            decorationBox = { inner ->
                if (value.isEmpty()) {
                    Text(text = placeholder, style = MochiFont.body(14.sp), color = MochiColor.textSecondary)
                }
                inner()
            }
        )
    }
}

@Composable
private fun DividerWithLabel(text: String) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Box(modifier = Modifier.weight(1f).height(1.dp).background(MochiColor.textSecondary.copy(alpha = 0.2f)))
        Text(text = text, style = MochiFont.caption(12.sp), color = MochiColor.textSecondary, modifier = Modifier.padding(horizontal = MochiSpacing.sm))
        Box(modifier = Modifier.weight(1f).height(1.dp).background(MochiColor.textSecondary.copy(alpha = 0.2f)))
    }
}

@Composable
private fun SocialButton(
    label: String,
    background: Color,
    contentColor: Color,
    modifier: Modifier = Modifier,
    icon: androidx.compose.ui.graphics.vector.ImageVector? = null,
    badge: String? = null,
    badgeColor: Color = Color.Unspecified,
    onClick: () -> Unit = {}
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(CircleShape)
            .background(background)
            .then(if (background == Color.White) Modifier.border(1.dp, MochiColor.textSecondary.copy(alpha = 0.15f), CircleShape) else Modifier)
            .clickable(onClick = onClick)
            .padding(vertical = 14.dp),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm, Alignment.CenterHorizontally),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (icon != null) {
            Icon(imageVector = icon, contentDescription = null, tint = contentColor, modifier = Modifier.size(18.dp))
        } else if (badge != null) {
            Text(text = badge, style = MochiFont.heading(15.sp).copy(fontWeight = FontWeight.Black), color = badgeColor)
        }
        Text(text = label, style = MochiFont.button(15.sp), color = contentColor)
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun AuthScreenPreview() {
    AuthScreenContent(
        uiState = AuthUiState(),
        onSignIn = { _, _ -> },
        onSignUp = { _, _ -> },
        onSendPasswordReset = {},
        onShowNotice = {}
    )
}
