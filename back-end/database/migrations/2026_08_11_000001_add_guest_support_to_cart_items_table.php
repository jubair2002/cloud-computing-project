<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('cart_items', 'guest_id')) {
            Schema::table('cart_items', function (Blueprint $table) {
                $table->string('guest_id')->nullable()->after('user_id')->index();
            });
        }

        Schema::table('cart_items', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id')->nullable()->change();
        });

        try {
            DB::statement('ALTER TABLE cart_items DROP INDEX cart_items_user_id_product_id_product_variant_id_unique');
        } catch (Throwable) {
            // The old unique index may already be gone or may have a different name.
        }

        $indexName = 'cart_items_user_id_guest_id_product_id_product_variant_id_unique';

        try {
            DB::statement('ALTER TABLE cart_items ADD UNIQUE '.$indexName.' (user_id, guest_id, product_id, product_variant_id)');
        } catch (Throwable) {
            // The index already exists; ignore the duplicate-index case.
        }
    }

    public function down(): void
    {
        try {
            DB::statement('ALTER TABLE cart_items DROP INDEX cart_items_user_id_guest_id_product_id_product_variant_id_unique');
        } catch (Throwable) {
            // Ignore when the index is already missing.
        }

        if (Schema::hasColumn('cart_items', 'guest_id')) {
            Schema::table('cart_items', function (Blueprint $table) {
                $table->dropColumn('guest_id');
            });
        }

        Schema::table('cart_items', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id')->nullable(false)->change();
        });
    }
};
