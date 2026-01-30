<?php

namespace App\Mail;

use App\Models\Threat;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ThreatAlertMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public Threat $threat
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: '[SentinelAI X] High-severity threat: ' . $this->threat->type . ' (severity ' . $this->threat->severity . '/10)',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.threat-alert',
        );
    }
}
