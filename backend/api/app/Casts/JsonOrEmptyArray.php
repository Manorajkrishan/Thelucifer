<?php

namespace App\Casts;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;
use JsonException;

/**
 * Cast JSON columns to array. Returns [] on decode failure to avoid 500s
 * when stored data is invalid (e.g. corrupted or non-JSON).
 */
class JsonOrEmptyArray implements CastsAttributes
{
    public function get(Model $model, string $key, mixed $value, array $attributes): array
    {
        if ($value === null || $value === '') {
            return [];
        }
        try {
            $decoded = json_decode($value, true, 512, JSON_THROW_ON_ERROR);
            return is_array($decoded) ? $decoded : [];
        } catch (JsonException) {
            return [];
        }
    }

    public function set(Model $model, string $key, mixed $value, array $attributes): mixed
    {
        if ($value === null || $value === []) {
            return null;
        }
        return json_encode(is_array($value) ? $value : (array) $value);
    }
}
