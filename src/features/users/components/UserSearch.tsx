'use client'

import { useState, useEffect } from 'react'
import { Input } from '@/components/ui/input'
import { Search, X } from 'lucide-react'
import { Button } from '@/components/ui/button'

interface UserSearchProps {
  value: string
  onChange: (value: string) => void
  placeholder?: string
}

export function UserSearch({
  value,
  onChange,
  placeholder = 'Search users by name or email...',
}: UserSearchProps) {
  const [localValue, setLocalValue] = useState(value)

  useEffect(() => {
    setLocalValue(value)
  }, [value])

  useEffect(() => {
    const timer = setTimeout(() => {
      onChange(localValue)
    }, 300) // 300ms debounce

    return () => clearTimeout(timer)
  }, [localValue, onChange])

  return (
    <div className="relative w-full max-w-sm">
      <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
      <Input
        type="text"
        placeholder={placeholder}
        value={localValue}
        onChange={(e) => setLocalValue(e.target.value)}
        className="pl-9 pr-8 h-10 w-full rounded-lg border border-border/60 bg-background hover:bg-muted/10 focus-visible:ring-1 focus-visible:ring-ring"
      />
      {localValue && (
        <Button
          type="button"
          variant="ghost"
          size="icon"
          onClick={() => setLocalValue('')}
          className="absolute right-1 top-1/2 h-8 w-8 -translate-y-1/2 text-muted-foreground hover:text-foreground"
        >
          <X className="h-4 w-4" />
        </Button>
      )}
    </div>
  )
}
