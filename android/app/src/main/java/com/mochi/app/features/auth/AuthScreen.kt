package com.mochi.app.features.auth

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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.components.GradientButton
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing

private enum class AuthMode { SIGN_IN, SIGN_UP }
private enum class AuthMethod { EMAIL, PHONE }

/** No Figma source — see OnboardingScreen.kt header note. Login methods per locked spec: Email +
 * Password, Google, Apple (mandatory alongside Google on iOS), Phone + OTP. No guest mode. */
@Composable
fun AuthScreen(modifier: Modifier = Modifier, onAuthenticated: () -> Unit = {}) {
    var mode by remember { mutableStateOf(AuthMode.SIGN_IN) }
    var method by remember { mutableStateOf(AuthMethod.EMAIL) }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }

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
                        modifier = Modifier.fillMaxWidth().clickable {}
                    )
                }
            } else {
                AuthTextField(value = phone, onValueChange = { phone = it }, placeholder = "Phone number")
            }

            Spacer(modifier = Modifier.height(MochiSpacing.lg))

            GradientButton(
                title = when {
                    method == AuthMethod.PHONE -> "Send OTP"
                    mode == AuthMode.SIGN_IN -> "Sign In"
                    else -> "Create Account"
                },
                onClick = onAuthenticated
            )

            Spacer(modifier = Modifier.height(MochiSpacing.md))
            DividerWithLabel(text = "or continue with")
            Spacer(modifier = Modifier.height(MochiSpacing.md))

            SocialButton(label = "Continue with Google", background = Color.White, contentColor = MochiColor.textPrimary, badge = "G", badgeColor = MochiColor.purple, onClick = onAuthenticated)
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            SocialButton(label = "Continue with Apple", background = MochiColor.textPrimary, contentColor = Color.White, onClick = onAuthenticated)
            Spacer(modifier = Modifier.height(MochiSpacing.sm))

            val phoneToggleLabel = if (method == AuthMethod.EMAIL) "Use phone number instead" else "Use email instead"
            Row(
                modifier = Modifier.fillMaxWidth().clickable {
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
    AuthScreen()
}
