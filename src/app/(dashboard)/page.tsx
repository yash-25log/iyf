import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Dashboard',
}

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">
          Welcome to Preacher&apos;s Zone
        </h1>
        <p className="text-muted-foreground mt-1">
          Your centralized knowledge repository for preaching resources.
        </p>
      </div>

      {/* Placeholder sections — will be replaced in Sprint 3–4 */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {[
          { label: 'Categories', desc: 'Browse by topic category' },
          { label: 'Recent Topics', desc: 'Latest preaching resources' },
          { label: 'Popular', desc: 'Most accessed content' },
        ].map((card) => (
          <div
            key={card.label}
            className="rounded-lg border border-border/60 bg-card p-5 space-y-1"
          >
            <h2 className="font-medium text-sm">{card.label}</h2>
            <p className="text-xs text-muted-foreground">{card.desc}</p>
          </div>
        ))}
      </div>
    </div>
  )
}
