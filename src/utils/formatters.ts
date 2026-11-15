export function formatCurrency(
  amount: number,
  currency: string = 'COP',
  locale: string = 'es-CO'
): string {
  const isNegative = amount < 0
  const absAmount = Math.abs(amount)

  const formatted = new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
    minimumFractionDigits: currency === 'COP' ? 0 : 2,
    maximumFractionDigits: currency === 'COP' ? 0 : 2,
  }).format(absAmount)

  return isNegative ? `-${formatted}` : formatted
}

export function formatDate(
  dateString: string | Date,
  format: 'short' | 'long' | 'relative' = 'short',
  locale: string = 'es-CO'
): string {
  const date = typeof dateString === 'string' ? new Date(dateString) : dateString

  if (isNaN(date.getTime())) return ''

  if (format === 'short') {
    // DD/MM/AAAA
    const day = String(date.getDate()).padStart(2, '0')
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const year = date.getFullYear()
    return `${day}/${month}/${year}`
  }

  if (format === 'long') {
    return new Intl.DateTimeFormat(locale, {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    }).format(date)
  }

  return date.toLocaleDateString(locale)
}
