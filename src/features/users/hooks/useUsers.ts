import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { fetchUsers, updateUser } from '../api'
import { toast } from 'sonner'

export function useUsers(filters?: { page?: number; limit?: number; search?: string }) {
  const queryClient = useQueryClient()

  // 1. Fetch Users query
  const query = useQuery({
    queryKey: ['users', filters],
    queryFn: () => fetchUsers(filters),
    placeholderData: (previousData) => previousData,
    staleTime: 5000,
  })

  // 2. Update User role/status mutation
  const updateMutation = useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: { role?: string; is_active?: boolean } }) =>
      updateUser(id, payload),
    onSuccess: (updatedUser) => {
      // Invalidate list query
      queryClient.invalidateQueries({ queryKey: ['users'] })
      // Optionally update individual query data if we cached details, but here we just list
      toast.success(`Successfully updated ${updatedUser.full_name || 'user'}`)
    },
    onError: (error: any) => {
      toast.error(error?.message || 'Failed to update user')
    },
  })

  return {
    users: query.data?.data || [],
    meta: query.data?.meta,
    isLoading: query.isLoading,
    isError: query.isError,
    error: query.error,
    refetch: query.refetch,
    updateUser: updateMutation.mutate,
    isUpdating: updateMutation.isPending,
  }
}
