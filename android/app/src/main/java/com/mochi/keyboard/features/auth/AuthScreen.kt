package com.mochi.keyboard.features.auth

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.GenericShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.R
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.util.findActivity

private enum class AuthMode { SIGN_IN, SIGN_UP }
private enum class AuthMethod { EMAIL, PHONE }

private const val APPLE_NOTICE = "Apple Sign-In isn't required on Android (it's an iOS App Store rule) - stubbed for demo."

// Signature Mochi Warm Pink-Orchid-Purple Gradient matching Home/Themes pages
private val HeaderGradient = Brush.verticalGradient(
    colors = listOf(
        Color(0xFF9012A7),
        Color(0xFFCE76DB),
        Color(0xFFE27FCC),
        Color(0xFF8F7CE9)
    )
)

private val PrimaryButtonGradient = Brush.horizontalGradient(
    colorStops = arrayOf(
        0.0f to Color(0xFFCE76DB),
        0.32f to Color(0xFFE27FCC),
        1.0f to Color(0xFF8F7CE9)
    )
)

private val WaveHeaderShape = GenericShape { size, _ ->
    val width = size.width
    val height = size.height
    moveTo(0f, 0f)
    lineTo(0f, height * 0.78f)
    cubicTo(
        width * 0.35f, height * 1.05f,
        width * 0.65f, height * 0.65f,
        width, height * 0.88f
    )
    lineTo(width, 0f)
    close()
}

@Composable
fun AuthScreen(
    modifier: Modifier = Modifier,
    onAuthenticated: () -> Unit = {},
    onBack: () -> Unit = {},
    viewModel: AuthViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val activity = remember(context) { context.findActivity() }

    AuthScreenContent(
        modifier = modifier,
        uiState = uiState,
        onBack = onBack,
        onSignIn = { email, password -> viewModel.signIn(email, password, onAuthenticated) },
        onSignUp = { email, password -> viewModel.signUp(email, password, onAuthenticated) },
        onSendPasswordReset = viewModel::sendPasswordReset,
        onShowNotice = viewModel::showNotice,
        onGoogleSignIn = {
            val act = activity
            if (act != null) viewModel.signInWithGoogle(act, onAuthenticated)
            else viewModel.showNotice("Couldn't start Google Sign-In from this screen.")
        },
        onSendPhoneCode = { phoneNumber -> viewModel.sendPhoneCode(phoneNumber) },
        onVerifyPhoneCode = { code -> viewModel.verifyPhoneCode(code, onAuthenticated) },
        onResetPhoneFlow = viewModel::resetPhoneFlow
    )
}

@Composable
private fun AuthScreenContent(
    modifier: Modifier = Modifier,
    uiState: AuthUiState,
    onBack: () -> Unit = {},
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
    var emailOrPhone by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var passwordVisible by remember { mutableStateOf(false) }
    var otpCode by remember { mutableStateOf("") }
    val codeSent = uiState.otpPhoneNumber != null

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(Color.White)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
        ) {
            // Top Wavy Gradient Header matching the signature Mochi Orchid-Pink-Purple color palette
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(260.dp)
                    .clip(WaveHeaderShape)
                    .background(HeaderGradient)
            ) {
                // Decorative ambient circles
                Canvas(modifier = Modifier.fillMaxSize()) {
                    drawCircle(
                        color = Color.White.copy(alpha = 0.10f),
                        radius = size.width * 0.4f,
                        center = Offset(size.width * 0.1f, size.height * 0.2f)
                    )
                    drawCircle(
                        color = Color.White.copy(alpha = 0.08f),
                        radius = size.width * 0.35f,
                        center = Offset(size.width * 0.9f, size.height * 0.7f)
                    )
                }

                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = MochiSpacing.lg, vertical = MochiSpacing.md),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Back button at top left
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(CircleShape)
                                .clickable { onBack() },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                contentDescription = "Back",
                                tint = Color.White,
                                modifier = Modifier.size(22.dp)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(4.dp))

                    // Tree/Leaf Logo inside White Circular Badge
                    Box(
                        modifier = Modifier
                            .size(54.dp)
                            .shadow(8.dp, CircleShape)
                            .clip(CircleShape)
                            .background(Color.White),
                        contentAlignment = Alignment.Center
                    ) {
                        MochiTreeLogo(modifier = Modifier.size(30.dp), tint = Color(0xFF9012A7))
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    // Welcome Header Text
                    Text(
                        text = if (mode == AuthMode.SIGN_IN) "Welcome" else "Create Account",
                        style = MochiFont.title(28.sp),
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )

                    Spacer(modifier = Modifier.height(2.dp))

                    Text(
                        text = if (mode == AuthMode.SIGN_IN) "Sign in to continue" else "Sign up to get started",
                        style = MochiFont.body(14.sp),
                        color = Color.White.copy(alpha = 0.90f)
                    )
                }
            }

            // Body Form Section
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = MochiSpacing.lg)
                    .padding(top = MochiSpacing.sm, bottom = MochiSpacing.lg),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                if (method == AuthMethod.EMAIL) {
                    // Email or Phone input field
                    StyledInputField(
                        value = emailOrPhone,
                        onValueChange = { emailOrPhone = it },
                        placeholder = "Email or Phone",
                        leadingIcon = {
                            Icon(
                                imageVector = Icons.Default.Person,
                                contentDescription = null,
                                tint = Color(0xFF9012A7),
                                modifier = Modifier.size(20.dp)
                            )
                        }
                    )

                    Spacer(modifier = Modifier.height(MochiSpacing.md))

                    // Password input field with trailing Eye toggle
                    StyledInputField(
                        value = password,
                        onValueChange = { password = it },
                        placeholder = "Password",
                        isPassword = !passwordVisible,
                        leadingIcon = {
                            Icon(
                                imageVector = Icons.Default.Lock,
                                contentDescription = null,
                                tint = Color(0xFF9012A7),
                                modifier = Modifier.size(20.dp)
                            )
                        },
                        trailingIcon = {
                            Icon(
                                imageVector = if (passwordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                contentDescription = "Toggle Password Visibility",
                                tint = Color(0xFF9CA3AF),
                                modifier = Modifier
                                    .size(20.dp)
                                    .clickable { passwordVisible = !passwordVisible }
                            )
                        }
                    )

                    if (mode == AuthMode.SIGN_IN) {
                        Spacer(modifier = Modifier.height(MochiSpacing.sm))
                        Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.CenterEnd) {
                            Text(
                                text = "Forgot Password?",
                                style = MochiFont.caption(13.sp),
                                color = Color(0xFF9012A7),
                                fontWeight = FontWeight.SemiBold,
                                modifier = Modifier.clickable {
                                    if (emailOrPhone.isBlank()) {
                                        onShowNotice("Enter your email address first.")
                                    } else {
                                        onSendPasswordReset(emailOrPhone)
                                    }
                                }
                            )
                        }
                    }
                } else if (!codeSent) {
                    StyledInputField(
                        value = emailOrPhone,
                        onValueChange = { emailOrPhone = it },
                        placeholder = "Phone number (e.g. +15551234567)",
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                        leadingIcon = {
                            Icon(
                                imageVector = Icons.Default.Phone,
                                contentDescription = null,
                                tint = Color(0xFF9012A7),
                                modifier = Modifier.size(20.dp)
                            )
                        }
                    )
                } else {
                    StyledInputField(
                        value = otpCode,
                        onValueChange = { otpCode = it },
                        placeholder = "6-digit code",
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword)
                    )
                    Spacer(modifier = Modifier.height(MochiSpacing.sm))
                    Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.CenterEnd) {
                        Text(
                            text = "Change number",
                            style = MochiFont.caption(13.sp),
                            color = Color(0xFF9012A7),
                            fontWeight = FontWeight.SemiBold,
                            modifier = Modifier.clickable {
                                otpCode = ""
                                onResetPhoneFlow()
                            }
                        )
                    }
                }

                if (uiState.errorMessage != null) {
                    Spacer(modifier = Modifier.height(MochiSpacing.sm))
                    Text(
                        text = uiState.errorMessage.orEmpty(),
                        style = MochiFont.caption(12.sp),
                        color = Color(0xFFEF4444),
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                if (uiState.resetEmailSent) {
                    Spacer(modifier = Modifier.height(MochiSpacing.sm))
                    Text(
                        text = "Password reset email sent - check your inbox.",
                        style = MochiFont.caption(12.sp),
                        color = Color(0xFF10B981),
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                Spacer(modifier = Modifier.height(MochiSpacing.lg))

                // Primary Action Button ("Login" / "Sign Up")
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .shadow(6.dp, RoundedCornerShape(16.dp))
                        .clip(RoundedCornerShape(16.dp))
                        .background(PrimaryButtonGradient)
                        .clickable {
                            if (uiState.isLoading) return@clickable
                            when {
                                method == AuthMethod.PHONE && codeSent ->
                                    if (otpCode.isBlank()) onShowNotice("Enter the code sent to your phone.") else onVerifyPhoneCode(otpCode)
                                method == AuthMethod.PHONE ->
                                    if (emailOrPhone.isBlank()) onShowNotice("Enter your phone number.") else onSendPhoneCode(emailOrPhone)
                                emailOrPhone.isBlank() || password.isBlank() -> onShowNotice("Enter both email/phone and password.")
                                mode == AuthMode.SIGN_IN -> onSignIn(emailOrPhone, password)
                                else -> onSignUp(emailOrPhone, password)
                            }
                        },
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = when {
                            uiState.isLoading -> "Please wait..."
                            method == AuthMethod.PHONE && codeSent -> "Verify Code"
                            method == AuthMethod.PHONE -> "Send OTP"
                            mode == AuthMode.SIGN_IN -> "Login"
                            else -> "Sign Up"
                        },
                        style = MochiFont.button(16.sp),
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(MochiSpacing.lg))

                // Divider: "or continue with"
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(1.dp)
                            .background(Color(0xFFE5E7EB))
                    )
                    Text(
                        text = "or continue with",
                        style = MochiFont.caption(12.sp),
                        color = Color(0xFF9CA3AF),
                        modifier = Modifier.padding(horizontal = MochiSpacing.sm)
                    )
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(1.dp)
                            .background(Color(0xFFE5E7EB))
                    )
                }

                Spacer(modifier = Modifier.height(MochiSpacing.lg))

                // Real Official Google and Apple Logo PNG Icons
                Row(
                    horizontalArrangement = Arrangement.spacedBy(18.dp, Alignment.CenterHorizontally),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Real Google Logo Button
                    SocialIconCard(
                        onClick = onGoogleSignIn
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.ic_google_logo),
                            contentDescription = "Google Sign In",
                            contentScale = ContentScale.Fit,
                            modifier = Modifier.size(28.dp)
                        )
                    }

                    // Real Apple Logo Button
                    SocialIconCard(
                        onClick = { onShowNotice(APPLE_NOTICE) }
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.ic_apple_logo),
                            contentDescription = "Apple Sign In",
                            contentScale = ContentScale.Fit,
                            modifier = Modifier.size(28.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(MochiSpacing.xl))

                // Bottom Mode Switcher Link: "Don't have an account? Sign up"
                Row(
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = if (mode == AuthMode.SIGN_IN) "Don't have an account? " else "Already have an account? ",
                        style = MochiFont.body(14.sp),
                        color = Color(0xFF6B7280)
                    )
                    Text(
                        text = if (mode == AuthMode.SIGN_IN) "Sign up" else "Sign in",
                        style = MochiFont.button(14.sp),
                        color = Color(0xFF9012A7),
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.clickable {
                            mode = if (mode == AuthMode.SIGN_IN) AuthMode.SIGN_UP else AuthMode.SIGN_IN
                        }
                    )
                }

                Spacer(modifier = Modifier.height(MochiSpacing.md))

                // Option to switch to phone OTP auth
                Text(
                    text = if (method == AuthMethod.EMAIL) "Use phone number instead" else "Use email instead",
                    style = MochiFont.caption(13.sp),
                    color = Color(0xFF9CA3AF),
                    modifier = Modifier.clickable {
                        if (method == AuthMethod.PHONE) {
                            otpCode = ""
                            onResetPhoneFlow()
                        }
                        method = if (method == AuthMethod.EMAIL) AuthMethod.PHONE else AuthMethod.EMAIL
                    }
                )
            }
        }
    }
}

@Composable
private fun StyledInputField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    isPassword: Boolean = false,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    leadingIcon: (@Composable () -> Unit)? = null,
    trailingIcon: (@Composable () -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(Color.White)
            .border(1.dp, Color(0xFFE2E8F0), RoundedCornerShape(16.dp))
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (leadingIcon != null) {
            leadingIcon()
            Spacer(modifier = Modifier.width(12.dp))
        }

        Box(modifier = Modifier.weight(1f)) {
            if (value.isEmpty()) {
                Text(
                    text = placeholder,
                    style = MochiFont.body(14.sp),
                    color = Color(0xFF9CA3AF)
                )
            }
            BasicTextField(
                value = value,
                onValueChange = onValueChange,
                textStyle = MochiFont.body(14.sp).copy(color = Color(0xFF1F2937)),
                visualTransformation = if (isPassword) PasswordVisualTransformation() else VisualTransformation.None,
                keyboardOptions = keyboardOptions,
                singleLine = true,
                cursorBrush = SolidColor(Color(0xFF9012A7)),
                modifier = Modifier.fillMaxWidth()
            )
        }

        if (trailingIcon != null) {
            Spacer(modifier = Modifier.width(8.dp))
            trailingIcon()
        }
    }
}

@Composable
private fun SocialIconCard(
    onClick: () -> Unit,
    content: @Composable () -> Unit
) {
    Box(
        modifier = Modifier
            .size(width = 76.dp, height = 58.dp)
            .shadow(3.dp, RoundedCornerShape(18.dp))
            .clip(RoundedCornerShape(18.dp))
            .background(Color.White)
            .border(1.dp, Color(0xFFE2E8F0), RoundedCornerShape(18.dp))
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        content()
    }
}

@Composable
private fun MochiTreeLogo(modifier: Modifier = Modifier, tint: Color) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            moveTo(w * 0.5f, h * 0.1f)
            cubicTo(w * 0.15f, h * 0.15f, w * 0.1f, h * 0.55f, w * 0.5f, h * 0.72f)
            cubicTo(w * 0.9f, h * 0.55f, w * 0.85f, h * 0.15f, w * 0.5f, h * 0.1f)
            close()
        }
        drawPath(path = path, color = tint)
        drawLine(
            color = Color.White,
            start = Offset(w * 0.5f, h * 0.35f),
            end = Offset(w * 0.5f, h * 0.65f),
            strokeWidth = w * 0.08f
        )
        drawLine(
            color = Color.White,
            start = Offset(w * 0.5f, h * 0.45f),
            end = Offset(w * 0.68f, h * 0.35f),
            strokeWidth = w * 0.07f
        )
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
