import { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ActivityIndicator, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '@/hooks/useAuth';
import { loginSchema } from '@myapp/shared';

export default function LoginScreen() {
  const router = useRouter();
  const { login, isLoading, error } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [validationErrors, setValidationErrors] = useState<Record<string, string>>({});

  const handleLogin = async () => {
    // Validate input
    const result = loginSchema.safeParse({ email, password });

    if (!result.success) {
      const errors: Record<string, string> = {};
      result.error.errors.forEach((err) => {
        if (err.path[0]) {
          errors[err.path[0].toString()] = err.message;
        }
      });
      setValidationErrors(errors);
      return;
    }

    setValidationErrors({});

    try {
      await login(email, password);
      router.replace('/(tabs)');
    } catch (err) {
      Alert.alert('Login Failed', error || 'An error occurred');
    }
  };

  return (
    <View className="flex-1 justify-center px-6 bg-gray-50">
      <View className="mb-8">
        <Text className="text-3xl font-bold text-gray-900 mb-2">Welcome Back</Text>
        <Text className="text-gray-600">Sign in to your account</Text>
      </View>

      <View className="space-y-4">
        {/* Email Input */}
        <View>
          <Text className="text-sm font-medium text-gray-700 mb-2">Email</Text>
          <TextInput
            className={`bg-white px-4 py-3 rounded-lg border ${
              validationErrors.email ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="you@example.com"
            value={email}
            onChangeText={setEmail}
            autoCapitalize="none"
            keyboardType="email-address"
            editable={!isLoading}
          />
          {validationErrors.email && (
            <Text className="text-red-500 text-sm mt-1">{validationErrors.email}</Text>
          )}
        </View>

        {/* Password Input */}
        <View>
          <Text className="text-sm font-medium text-gray-700 mb-2">Password</Text>
          <TextInput
            className={`bg-white px-4 py-3 rounded-lg border ${
              validationErrors.password ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="Enter your password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            editable={!isLoading}
          />
          {validationErrors.password && (
            <Text className="text-red-500 text-sm mt-1">{validationErrors.password}</Text>
          )}
        </View>

        {/* Error Message */}
        {error && (
          <View className="bg-red-50 border border-red-200 rounded-lg p-4">
            <Text className="text-red-800">{error}</Text>
          </View>
        )}

        {/* Login Button */}
        <TouchableOpacity
          className={`bg-blue-600 py-4 rounded-lg ${isLoading ? 'opacity-50' : ''}`}
          onPress={handleLogin}
          disabled={isLoading}
        >
          {isLoading ? (
            <ActivityIndicator color="white" />
          ) : (
            <Text className="text-white text-center font-semibold text-lg">Sign In</Text>
          )}
        </TouchableOpacity>

        {/* Forgot Password Link */}
        <TouchableOpacity onPress={() => router.push('/(auth)/forgot-password')}>
          <Text className="text-blue-600 text-center">Forgot Password?</Text>
        </TouchableOpacity>

        {/* Sign Up Link */}
        <View className="flex-row justify-center mt-4">
          <Text className="text-gray-600">Don't have an account? </Text>
          <TouchableOpacity onPress={() => router.push('/(auth)/signup')}>
            <Text className="text-blue-600 font-semibold">Sign Up</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}
