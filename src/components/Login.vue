<template>
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <img src="/1.png" alt="BeyzTrack Logo" class="login-logo" />
                <h1 class="login-title">BeyzTrack</h1>
                <p class="login-subtitle">Monitoring & Reporting System</p>
            </div>
            
            <form @submit.prevent="login" class="login-form">
                <div class="form-group">
                    <label for="username">{{ $t("Username") }}</label>
                    <input 
                        type="text" 
                        id="username" 
                        v-model="username" 
                        class="form-control" 
                        :placeholder="$t('Enter username')"
                        required 
                    />
                </div>
                
                <div class="form-group">
                    <label for="password">{{ $t("Password") }}</label>
                    <input 
                        type="password" 
                        id="password" 
                        v-model="password" 
                        class="form-control" 
                        :placeholder="$t('Enter password')"
                        required 
                    />
                </div>
                
                <div class="form-check">
                    <input 
                        type="checkbox" 
                        id="remember" 
                        v-model="remember" 
                        class="form-check-input" 
                    />
                    <label for="remember" class="form-check-label">
                        {{ $t("Remember me") }}
                    </label>
                </div>
                
                <button type="submit" class="btn btn-primary btn-login" :disabled="loading">
                    <i v-if="loading" class="fas fa-spinner fa-spin"></i>
                    <i v-else class="fas fa-sign-in-alt"></i>
                    {{ loading ? $t("Logging in...") : $t("Login") }}
                </button>
            </form>
            
            <div class="login-footer">
                <p class="text-muted">{{ $t("BeyzTrack Monitoring System") }}</p>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "Login",
    data() {
        return {
            username: "",
            password: "",
            remember: true,
            loading: false
        };
    },
    methods: {
        async login() {
            this.loading = true;
            
            try {
                // Basit login simülasyonu
                if (this.username && this.password) {
                    this.$root.loggedIn = true;
                    this.$root.allowLoginDialog = false;
                    this.$root.username = this.username;
                    this.$root.usernameFirstChar = this.username.charAt(0).toUpperCase();
                    
                    this.$root.toastSuccess("Giriş başarılı!");
                    this.$router.push("/dashboard");
                } else {
                    this.$root.toastError("Kullanıcı adı ve şifre gerekli");
                }
            } catch (error) {
                this.$root.toastError("Giriş hatası: " + error.message);
            } finally {
                this.loading = false;
            }
        }
    }
};
</script>

<style lang="scss" scoped>
.login-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 1rem;
}

.login-card {
    background: var(--bs-body-bg);
    border-radius: 1rem;
    box-shadow: 0 20px 40px rgba(0,0,0,0.1);
    padding: 2rem;
    width: 100%;
    max-width: 400px;
    text-align: center;
}

.login-header {
    margin-bottom: 2rem;

    .login-logo {
        width: 80px;
        height: 80px;
        margin-bottom: 1rem;
        border-radius: 50%;
        background: white;
        padding: 10px;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }

    .login-title {
        color: var(--bs-primary);
        font-weight: 700;
        margin-bottom: 0.5rem;
    }

    .login-subtitle {
        color: var(--bs-secondary);
        margin: 0;
    }
}

.login-form {
    text-align: left;

    .form-group {
        margin-bottom: 1.5rem;

        label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: var(--bs-body-color);
        }

        .form-control {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid var(--bs-border-color);
            border-radius: 0.5rem;
            font-size: 1rem;
            transition: border-color 0.2s ease;

            &:focus {
                outline: none;
                border-color: var(--bs-primary);
                box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1);
            }
        }
    }

    .form-check {
        margin-bottom: 1.5rem;
        display: flex;
        align-items: center;

        .form-check-input {
            margin-right: 0.5rem;
        }

        .form-check-label {
            margin: 0;
            color: var(--bs-body-color);
        }
    }

    .btn-login {
        width: 100%;
        padding: 0.75rem;
        font-size: 1rem;
        font-weight: 500;
        border-radius: 0.5rem;
        transition: all 0.2s ease;

        &:hover:not(:disabled) {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(13, 110, 253, 0.3);
        }

        &:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
    }
}

.login-footer {
    margin-top: 2rem;
    padding-top: 1rem;
    border-top: 1px solid var(--bs-border-color);

    p {
        margin: 0;
        font-size: 0.9rem;
    }
}

@media (max-width: 480px) {
    .login-card {
        padding: 1.5rem;
    }
}
</style>